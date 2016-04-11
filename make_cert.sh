#!/bin/bash

source /home/centcom-ca/protected/common

DEVICE_NAME="${1}"
if [ -z "${DEVICE_NAME}" ]; then
	echo "Usage: ${0} <name>"
	exit ${ERROR_MISSING_DEVICE_NAME}
fi

#CA="/home/centcom-ca/protected/intermediary"
#CA_KEY="${CA}/device_ca-centcom-coal.key"
#CA_CERT="${CA}/device_ca-centcom-coal.crt"

#BITS=16384
#DAYS_VALID=1000

DEVICE_KEY="device_${DEVICE_NAME}.key"
DEVICE_CERT_REQ="device_${DEVICE_NAME}.csr"
DEVICE_CERT="device_${DEVICE_NAME}.crt"
DEVICE_CERT_CHAIN="device_${DEVICE_NAME}.fullChain.crt"


generatePrivateKey "${DEVICE_KEY}" "${DEVICE_NAME}"
if [ $? -eq 0 ]; then

	generateCertificateRequest "${DEVICE_KEY}" "${DEVICE_CERT_REQ}" "${DEVICE_NAME}"
	if [ $? -eq 0 ]; then

		verifyCertificateCrlChain "${CA_ROOT_CERT}" "${CA_ROOT_CRL_PEM}" "${CA_INTERMEDIATE_CERT}"
		if [ $? -eq 0 ]; then
			echo "Validated ${CA_INTERMEDIATE_NAME}'s Certificate"
		fi

		signAuthorityCertificate "${CA_INTERMEDIATE_CERT}" "${CA_INTERMEDIATE_CONF}" "${CA_INTERMEDIATE_NAME}" "${DEVICE_CERT_REQ}" "${DEVICE_KEY} "${DEVICE_NAME}"
		if [ $? -eq 0 ]; then

			chain=$(makeList ${CA_INTERMEDIATE_CERT_CHAIN} ${DEVICE_CERT})
			generateCertificateChain "${chain}" "${DEVICE_CERT_CHAIN}"
			if [ $? -eq 0 ]; then

				verifyCertificateChain "${DEVICE_CERT_CHAIN}" "${DEVICE_CERT}"
				if [ $? -eq 0 ]; then
					echo "Validated Certificate Chain"
				fi

				verifyCertificateCrlChain "${CA_INTERMEDIATE_CERT_CHAIN}" "${CA_INTERMEDIATE_CRL_PEM}" "${DEVICE_CERT}"
				if [ $? -eq 0 ]; then
					echo "Validated Certificate Chain using ${CA_INTERMEDIATE_NAME}'s CRL"
				fi

				verifyCertificate "${DEVICE_CERT}"
			fi
		fi
	fi
fi
