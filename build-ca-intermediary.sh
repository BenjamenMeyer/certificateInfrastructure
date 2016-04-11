#!/bin/bash

source /home/centcom-ca/protected/common

generatePrivateKey "${CA_INTERMEDIATE_KEY}" "${CA_INTERMEDIATE_NAME} Key"
if [ $? -eq 0 ]; then

	echo
	echo "${SPACER}**************************************************************************************************"
	echo "${SPACER}WARNING: Make sure to fill out the Common Name propertly for ${CA_INTERMEDIATE_NAME}"
	echo "${SPACER}**************************************************************************************************"
	echo
	generateCertificateRequest "${CA_INTERMEDIATE_KEY}" "${CA_INTERMEDIATE_CERT_REQ}" "${CA_INTERMEDIATE_NAME} Certificate Request"
	if [ $? -eq 0 ]; then

		signAuthorityCertificate "${CA_ROOT_CERT}" "${CA_ROOT_CONF}" "${CA_ROOT_NAME}" "${CA_INTERMEDIATE_CERT_REQ}" "${CA_INTERMEDIATE_CERT}" "${CA_INTERMEDIATE_NAME}"
		if [ $? -eq 0 ]; then

			generateCertificateCrl "${CA_ROOT_KEY}" "${CA_ROOT_CERT}" "${CA_ROOT_CRL_PEM}" "${CA_ROOT_CRL_DER}" "${CA_ROOT_CONF}" "${CA_ROOT_NAME}"
			if [ $? eq 0 ]; then

				initializeAuthorityIndex "${CA_INTERMEDIATE_INDEX}" "${CA_INTERMEDIATE_NAME} Index"
				if [ $? -eq 0 ]; then

					initializeAuthoritySerial "${CA_INTERMEDIATE_SERIAL}" "${CA_INTERMEDIATE_NAME} Serial"
					if [ $? -eq 0 ]; then

						initializeAuthorityCrlNumber "${CA_INTERMEDIATE_CRLNUMBER}" "${CA_INTERMEDIATE_NAME} CRL Number"
						if [ $? -eq 0 ]; then

							chain=$(makeList ${CA_ROOT_CERT} ${CA_INTERMEDIATE_CERT})
							generateCertificateChain "${chain}" "${CA_INTERMEDIATE_CERT_CHAIN}"
							if [ $? -eq 0 ]; then

								verifyCertificate "${CA_INTERMEDIATE_CERT}"
								exit $?
							fi
						fi
					fi
				fi
			fi
		fi
	fi
fi
