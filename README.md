# secrets

A simple way to share highly secret information among up to eight people,
without requiring use of a common password or complicated public key setup.

Notes:
    * This only works on Linux
    * You must be able to `sudo(8)` to `root` to use this

# Initializing the secrets file

To create a new secrets vault or reinitialize an existing one:

```
	sudo ./initialize-secrets.sh
```

Then update "Slot 0" in the list below with your name.

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
