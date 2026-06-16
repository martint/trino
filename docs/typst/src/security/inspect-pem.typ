#import "/lib/trino-docs.typ": *

#anchor("doc-security-inspect-pem")
= PEM files

PEM \(Privacy Enhanced Mail\) is a standard for public key and certificate information, and an encoding standard used to transmit keys and certificates.

Trino supports PEM files. If you want to use other supported formats, see:

- #link(label("doc-security-inspect-jks"))[JKS keystores]
- PKCS 12 stores. \(Look up alternate commands for these in #raw("openssl") references.\)

A single PEM file can contain either certificate or key pair information, or both in the same file. Certified keys can contain a chain of certificates from successive certificate authorities.

Follow the steps in this topic to inspect and validate key and certificate in PEM files. See #link(label("ref-troubleshooting-keystore"))[troubleshooting-keystore] to validate JKS keystores.

#anchor("ref-inspect-pems")

== Inspect PEM file

The file name extensions shown on this page are examples only; there is no extension naming standard.

You may receive a single file that includes a private key and its certificate, or separate files. If you received separate files, concatenate them into one, typically in order from key to certificate. For example:

#code-block("shell", "cat clustercoord.key clustercoord.cert > clustercoord.pem")

Next, use the #raw("cat") command to view this plain text file. For example:

#code-block("shell", "cat clustercoord.pem | less")

Make sure the PEM file shows at least one #raw("KEY") and one #raw("CERTIFICATE") section. A key section looks something like the following:

#code-block("text", "-----BEGIN PRIVATE KEY-----
MIIEowIBAAKCAQEAwJL8CLeDFAHhZe3QOOF1vWt4Vuk9vyO38Y1y9SgBfB02b2jW
....
-----END PRIVATE KEY-----")

If your key section reports #raw("BEGIN ENCRYPTED PRIVATE KEY") instead, this means the key is encrypted and you must use the password to open or inspect the key. You may have specified the password when requesting the key, or the password could be assigned by your site's network managers. Note that password protected PEM files are not supported by Trino.

If your key section reports #raw("BEGIN EC PRIVATE KEY") or #raw("BEGIN DSA PRIVATE KEY"), this designates a key using Elliptical Curve or DSA alternatives to RSA.

The certificate section looks like the following example:

#code-block("text", "-----BEGIN CERTIFICATE-----
MIIDujCCAqICAQEwDQYJKoZIhvcNAQEFBQAwgaIxCzAJBgNVBAYTAlVTMRYwFAYD
....
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIDwjCCAqoCCQCxyqwZ9GK50jANBgkqhkiG9w0BAQsFADCBojELMAkGA1UEBhMC
....
-----END CERTIFICATE-----")

The file can show a single certificate section, or more than one to express a chain of authorities, each certifying the previous.

#anchor("ref-validate-pems")

== Validate PEM key section

This page presumes your system provides the #raw("openssl") command from OpenSSL 1.1 or later.

Test an RSA private key's validity with the following command:

#code-block("text", "openssl rsa -in clustercoord.pem -check -noout")

Look for the following confirmation message:

#code-block("text", "RSA key ok")

#note[
Consult #raw("openssl") references for the appropriate versions of the verification commands for EC or DSA keys.
]

== Validate PEM certificate section

Analyze the certificate section of your PEM file with the following #raw("openssl") command:

#code-block("text", "openssl x509 -in clustercoord.pem -text -noout")

If your certificate was generated with a password, #raw("openssl") prompts for it. Note that password protected PEM files are not supported by Trino.

In the output of the #raw("openssl") command, look for the following characteristics:

- Modern browsers now enforce 398 days as the maximum validity period for a certificate. Look for #raw("Not Before") and #raw("Not After") dates in the #raw("Validity") section of the output, and make sure the time span does not exceed 398 days.
- Modern browsers and clients require the #strong[Subject Alternative Name] \(SAN\) field. Make sure this shows the DNS name of your server, such as #raw("DNS:clustercoord.example.com"). Certificates without SANs are not supported.

If your PEM file shows valid information for your cluster, proceed to configure the server, as described in #link(label("ref-cert-placement"))[cert-placement] and #link(label("ref-configure-https"))[configure-https].
