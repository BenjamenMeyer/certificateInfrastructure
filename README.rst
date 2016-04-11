==========================
Certificate Infrastructure
==========================

Tools for Building your own CA

Overview
========

This repository contains a basic set of tools to make building and running your own self-signed CA simple to do.

Configuration
=============

There are three files that need configuration;

- ```common```
- the CA Configuration Files

```common```
------------

The ```common``` file has a series of functions and variables used to build the CA and sign the certificates. To this end, it uses a lot of variables to ensure everything remains in-sync. The following variables will need to be adjusted for unique operation:

- CA_NAME
- CA_USER
- CA_HOME
- CA_BASE
- CA_ROOT_NAME
- CA_INTERMEDIATE_NAME

You may also wish to twiddle the following:

- DAYS_VALID

By default, the configuration creates 16386 keys (16kb). At present, this is the maximum keysize that OpenSSL will allow. Lower bit settings may be used; however, be careful not to go too low. At the time of writing this the minimally accepted bit size is 4096. Larger Bit sizes take longer to generate, and also longer to crack. Thus larger is _usually_ safer. The used bit size can be adjusted via the ```BITS``` parameter.

CA Configuration Files
----------------------

Two of the tools requi^res a configuration file. A good example of the configuration file can be located at https://raymii.org/s/tutorials/OpenSSL_command_line_Root_and_Intermediate_CA_including_OCSP_CRL%20and_revocation.html, a copy of which is provided here:

.. code-block:: text

	[ ca ]
	default_ca = myca

	[ crl_ext ]
	issuerAltName=issuer:copy 
	authorityKeyIdentifier=keyid:always

	[ myca ]
	dir = ./
	new_certs_dir = $dir
	unique_subject = no
	certificate = $dir/rootca.crt
	database = $dir/certindex
	private_key = $dir/rootca.key
	serial = $dir/certserial
	default_days = 730
	default_md = sha256
	policy = myca_policy
	x509_extensions = myca_extensions
	crlnumber = $dir/crlnumber
	default_crl_days = 730

	[ myca_policy ]
	commonName = supplied
	stateOrProvinceName = supplied
	countryName = optional
	emailAddress = optional
	organizationName = supplied
	organizationalUnitName = optional

	[ myca_extensions ]
	basicConstraints = critical,CA:TRUE
	keyUsage = critical,any
	subjectKeyIdentifier = hash
	authorityKeyIdentifier = keyid:always,issuer
	keyUsage = digitalSignature,keyEncipherment,cRLSign,keyCertSign
	extendedKeyUsage = serverAuth
	crlDistributionPoints = @crl_section
	subjectAltName  = @alt_names
	authorityInfoAccess = @ocsp_section

	[ v3_ca ]
	basicConstraints = critical,CA:TRUE,pathlen:0
	keyUsage = critical,any
	subjectKeyIdentifier = hash
	authorityKeyIdentifier = keyid:always,issuer
	keyUsage = digitalSignature,keyEncipherment,cRLSign,keyCertSign
	extendedKeyUsage = serverAuth
	crlDistributionPoints = @crl_section
	subjectAltName  = @alt_names
	authorityInfoAccess = @ocsp_section

	[alt_names]
	DNS.0 = Sparkling Intermidiate CA 1
	DNS.1 = Sparkling CA Intermidiate 1

	[crl_section]
	URI.0 = http://pki.sparklingca.com/SparklingRoot.crl
	URI.1 = http://pki.backup.com/SparklingRoot.crl

	[ocsp_section]
	caIssuers;URI.0 = http://pki.sparklingca.com/SparklingRoot.crt
	caIssuers;URI.1 = http://pki.backup.com/SparklingRoot.crt
	OCSP;URI.0 = http://pki.sparklingca.com/ocsp/
	OCSP;URI.1 = http://pki.backup.com/ocsp/

To work properly with the provided scripts, the ```[ myca ]``` section will need to be in sync with the variables in ```common```. One big change over the source is setting ```default_md``` to ```sha256``` instead of ```sha1```, which is now considered too weak. The ```alt_names```, ```crl_section```, and ```ocsp_section``` will also need adjustments. Remember, both the Root and Intermediate CA's need their own configuration.

.. code-block:: text

	Note: It is possible to use a single configuration file for both; however, the tools as written expect to have individual configuration files each CA.

Operation
=========

Once the configuration is in place, then operation occurs in two phases:

- First run
- On-going usage

To help with repeatability, the scripts can be run multiple times. If the expected files are present then they will skip re-creating those files. 

First Run
---------

The first time the scripts are run is the most complex as it means setting up both CA's. This is mostly a matter of ensuring that some of the entry values are correct - namely the Common Name value.

To start, run the ```build-ca-root.sh``` script:

.. code-block:: bash

	$ ./build-ca-root.sh

After a while it will ask some questions. This will create the primary CA.

Note: If absolute security is desired, then once the Intermediate CA is setup most of the data for the CA Root should be moved off-line. Only the CRL files (PEM and DER formats) and Public Certificate can be kept accessible as these are required for providing revocations and proving the certificate chain later on.

Once the Root CA is built, then it will be time to build the Intermediate CA:

.. code-block:: bash

	$ ./build-ca-intermediary.sh

The same questions will be asked. Once the script is done, then the newly minted CA's are ready to be published to your sites and used to generate End-User and Device certificates.


On-going Runs
-------------

If you control all the devices and end-users directly then the end-user certificates can be generated using the ```make_cert.sh``` script:

.. code-block:: bash

	$ ./make_cert.sh mydevice

Unlike the CA's, this script requires the device name primarily because it must generate new filenames for each device. It is left to the user to make them unique.
