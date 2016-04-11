#!/bin/bash

source /home/centcom-ca/protected/common

generatePrivateKey "${CA_ROOT_KEY}" "${CA_ROOT_NAME} Key"
if [ $? -eq 0 ]; then

	generateAuthorityCertificate "${CA_ROOT_KEY}" "${CA_ROOT_CERT}" "${CA_ROOT_NAME} Certificate"
	if [ $? -eq 0 ]; then

		initializeAuthorityIndex "${CA_ROOT_INDEX}" "${CA_ROOT_NAME} Index"
		if [ $? -eq 0 ]; then

			initializeAuthoritySerial "${CA_ROOT_SERIAL}" "${CA_ROOT_NAME} Serial"
			if [ $? -eq 0 ]; then

				initializeAuthorityCrlNumber "${CA_ROOT_CRLNUMBER}" "${CA_ROOT_NAME} CRL Number"
				if [ $? -eq 0 ]; then

					verifyCertificate "${CA_ROOT_CERT}"
					exit $?
				fi
			fi
		fi
	fi
fi
