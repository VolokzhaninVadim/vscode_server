#!/bin/sh

# Create variables
GPG_KEY=634064C6
GPG_PASSPHRASE=/home/volokzhanin/.gnupg/backup_passphrase

# Decrypt
for i in *zst.gpg;
do
gpg --decrypt \
    --batch \
    --passphrase $GPG_PASSPHRASE \
    --recipient $GPG_KEY \
    --passphrase-file $GPG_PASSPHRASE \
    "$i" > "$i".tar.zst;
done;

# Unzip
for i in *.tar.zst;
do
tar --preserve-permissions \
    --extract \
    --zstd \
    --file "$i";

rm $i;
done;
