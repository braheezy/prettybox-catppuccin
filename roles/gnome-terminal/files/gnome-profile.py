#!/usr/bin/env python
'''
Small wrapper to basic `dconf` calls to perform operations on /org/gnome/terminal/legacy/profiles:
where gnome-terminal profiles are saved.

@flags
    --check-profile-exists: Return True if profile exists
    --add: Create a new minimal profile with name
    --make-default: If True, make the profile the default. This is the default behavior.
'''
import argparse
import subprocess
import sys
import uuid

DCONF_DIR = "/org/gnome/terminal/legacy/profiles:"

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('profile', type=str)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--add', action='store_true')
    parser.add_argument('--make-default', action='store_true', default=True)

    args = parser.parse_args()

    profile = args.profile

    # Get list of current profiles by UUID.
    # Do this over reading the actual `list` key because it handles a few corner error cases better.
    result = subprocess.run(['dconf', 'list', f"{DCONF_DIR}/"],
                            capture_output=True,
                            text=True)
    profile_list = [
        prof for prof in result.stdout.split('\n') if prof.startswith(":")
    ]

    # Convert the UUIDs to human-readable profile names.
    profile_names = []
    for prof in profile_list:
        result = subprocess.run(
            ['dconf', 'read', f'{DCONF_DIR}/{prof}visible-name'],
            capture_output=True,
            text=True)
        profile_names.append(result.stdout.strip('\n'))

    # Returns True if the profile is in the list of names.
    profile_exists = lambda: f"'{profile}'" in profile_names

    if args.check:
        print(profile_exists())
        sys.exit()

    if args.add and not profile_exists():
        # Generate new UUID
        new_uuid = uuid.uuid4()

        # Get the current profile list value
        result = subprocess.run(['dconf', 'read', f'{DCONF_DIR}/list'],
                                capture_output=True,
                                text=True)

        if result.stdout != '':
            # Convert to an python list
            result = result.stdout.lstrip('[').rstrip(']\n').split(', ')

            # Append uuid to end
            result.append(f"'{new_uuid}'")

            # Rebuild the string-version of the list
            new_profile_list = '[' + ', '.join(result) + ']'

            # Write the new list back
            subprocess.run(
                ['dconf', 'write', f'{DCONF_DIR}/list', new_profile_list],
                check=True)
        else:
            # No current profiles exist. This is the first one.
            subprocess.run(
                ['dconf', 'write', f'{DCONF_DIR}/list', f"['{new_uuid}']"],
                check=True)

        # Ensure profile is visible
        subprocess.run([
            'dconf', 'write', f'{DCONF_DIR}/:{new_uuid}/visible-name',
            f"'{profile}'"
        ],
                       check=True)

        if args.make_default:
            subprocess.run(
                ['dconf', 'write', f"{DCONF_DIR}/default", f"'{new_uuid}'"],
                capture_output=True,
                text=True)
