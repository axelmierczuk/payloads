
#!/bin/sh

encrypt()
{
    hex_aes_key=$(echo "$aes_key" | openssl base64 -d | xxd -c1000 -p)
    hex_aes_iv=$(echo "$aes_iv" | openssl base64 -d | xxd -c1000 -p)
    hex_mac_key=$(echo "$mac_key" | openssl base64 -d | xxd -c1000 -p)

    hex_ciphertext=$(printf "$plaintext" |
                     openssl aes-256-cbc -K "$hex_aes_key" -iv "$hex_aes_iv" |
                     xxd -c1000 -p)

    b64_ciphertext=$(printf "$plaintext" |
                     openssl aes-256-cbc -K "$hex_aes_key" -iv "$hex_aes_iv" \
                     -base64)

    b64_mac=$(echo "$hex_aes_iv$hex_ciphertext" | xxd -r -p |
              openssl sha256 -binary -mac hmac -macopt hexkey:$hex_mac_key |
              openssl base64)

    echo "$b64_mac:$aes_iv:$b64_ciphertext"
}

encrypt "$@"
