# secrets

A simple way to share highly secret information among up to eight people,
without requiring use of a common password or complicated public key setup.

Notes:
* This only works on Linux
* You must be able to `sudo(8)` to `root` to use this

# How it Works

This project creates a disk image which:
* Is stored in regular file
* Is very securely encrypted, so that only those who have a password can access it
* Can be accessed by up to eight different people using their own individual passwords (no password sharing required)
* Allows for the erasing of an individual password if a member of the group leaves (without needing to know their password)
* Is under GIT source control and can be easily and safely shared and distributed

This is useful in an organization where for redundancy you want multiple people to be able to access certain files, but you don't want to use a single shared secret that might be hard to control, especially if people might leave the group at some point.

The disk image is created via `cryptsetup(8)` and mounted via loopback mounts. You can store whatever files you want in it, just like a physical disk.

# Initializing the secrets file

To create a new secrets vault or reinitialize an existing one:

```
	sudo ./initialize-secrets.sh SIZE
```

where SIZE is the size of the image in megabytes. A size of at least 5 megabytes is recommended.

You will be asked for an initial password. When you're done, update "Slot 0" in the list below with your name.

# Reading/Updating Secrets

To reveal the secrets:

```
	sudo ./mount-secrets.sh
```

This will reveal the secrets in the directory `./secrets.mount`.

When you're done viewing or updating the secrets, run:

```
	sudo ./unmount-secrets.sh
```

Then commit your changes (if any).

# Adding a New User/Password

The secrets file should be unmounted before you do this. You will also need an existing password.

Pick an "(emtpty)" slot number N from the list below, then set the new password in slot N via:

```
    sudo cryptsetup luksAddKey --key-slot [N] filesystem.bin
```

Then replace `(empty)` with the person's name in the list below and commit changes.

# Removing a User/Password

You can erase key slot N (where N is from 0 to 7) via:

```
    sudo cryptsetup luksKillSlot filesystem.bin [N]
```

Then change slot N in the list below back to `(empty)` and commit changes.

# LUKS Key Slots

Keep this list up to date so you know which slot to nuke if someone leaves the group.

```
    Slot 0: (empty)
    Slot 1: (empty)
    Slot 2: (empty)
    Slot 3: (empty)
    Slot 4: (empty)
    Slot 5: (empty)
    Slot 6: (empty)
    Slot 7: (empty)
```

# To view LUKS meta-data

```
    cryptsetup luksDump filesystem.bin
```
