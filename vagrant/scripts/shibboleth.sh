#!/bin/sh -e

# Shibboleth installation script

#NOTE: 
#If you change the configuration of Shibboleth, you need to copy the generated
#'sp-metadata.xml' and 'idp-metadata.xml' to the IDP machine in the folder 
#'/opt/shibboleth-idp/metadata'. The file 'relying-party.xml' must be copied
#to the folder '/opt/shibboleth-idp/conf' on the IDP machine."

USE_SHIBBOLETH=true    
SP_HOST="10.70.10.80"         #probably something like "sp.eox.at" in the future
IDP_HOST="192.168.16.147"     #probably something like "idp.eox.at" in the future    
PROTECTED_DIR="/browse"

SP_KEY_FILE="/etc/shibboleth/sp-key.pem"                 #SP key 
SP_CERT_FILE="/etc/shibboleth/sp-cert.pem"               #SP certificate
IDP_KEY_FILE="/etc/shibboleth/idp-key.pem"               #IDP key
IDP_CERT_FILE="/etc/shibboleth/idp-cert.pem"             #IDP certificate

SP_CERT_FILE_2="/etc/pki/tls/certs/sp-cert.pem"
SP_KEY_FILE_2="/etc/pki/tls/private/sp-key.pem"
SP_NAME="v-manip"

IDP_PORT="443"               
IDP_SOAP="8443"
IDP_ENTITYID="https://$IDP_HOST/shibboleth"
HOST_EXTENSION="eox.at"
SP_ORG_DISP_NAME="V-Manip Server"
SP_HOME_FULL_URL="http://eox.at"
SP_HOME_BASE_URL="https://$SP_HOST"
SP_ENTITYID="https://$SP_HOST/shibboleth"
SP_CONTACT="webmaster@eox.at"

##################################################################

if "$USE_SHIBBOLETH" ; then
    echo "Installing Shibboleth"

    # add the shibboleth rpm repository
    cd /etc/yum.repos.d/
    wget http://download.opensuse.org/repositories/security://shibboleth/CentOS_CentOS-6/security:shibboleth.repo
    cd -

    # Set exclude in security:shibboleth.repo
    if ! grep -Fxq "exclude=libxerces-c-3_1" /etc/yum.repos.d/CentOS-Base.repo ; then
        sed -e 's/^\[security_shibboleth\]$/&\nexclude=libxerces-c-3_1/' -i /etc/yum.repos.d/security:shibboleth.repo
    fi

    # TODO includepkg / excludepkg 
    #yum install -y libxerces-c-3_1 shibboleth mod_ssl openssl
    yum install -y shibboleth mod_ssl openssl
    
    # delete the config files (we will create them from scratch)
    rm -f /etc/shibboleth/attribute-policy.xml /etc/shibboleth/attribute-map.xml /etc/shibboleth/shibboleth2.xml

    # sample keys & certs provided by sso_checkpoint.tgz
    # TODO: test if files exist and DON'T overwrite them
    echo "Adding certificates"
    cat << EOF > "$IDP_CERT_FILE"
-----BEGIN CERTIFICATE-----
MIIDxzCCAq+gAwIBAgIJAI7D9hjVkWY1MA0GCSqGSIb3DQEBBQUAMEsxCzAJBgNV
BAYTAkFUMQ0wCwYDVQQIEwRXSUVOMQ0wCwYDVQQHEwRXaWVuMQwwCgYDVQQKEwNF
b3gxEDAOBgNVBAMTB3YtbWFuaXAwHhcNMTMxMTE5MTI1NjIzWhcNMTYxMTE4MTI1
NjIzWjBLMQswCQYDVQQGEwJBVDENMAsGA1UECBMEV0lFTjENMAsGA1UEBxMEV2ll
bjEMMAoGA1UEChMDRW94MRAwDgYDVQQDEwd2LW1hbmlwMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEA3FbroTIWrFMUNKdvY07Rgn/PtEe6zD/AMm+OaZcY
tAzzZYydNWRfOBM7KmtFNCj47j42nyRRxkaSYqYSWx5elTqu8INmBxXY8XhPbrGc
Eyl+f7MKwxNCiHagZDNslB0b76fSjqBV6tJ9/wpYthkcUkV/DEdIC+tXGWVEkN45
jUxXrLIzOdgyXz8ip9JJp33mF+ZPkutpW7+BqzgPwrHTtBcuhODnQ1Alh+PM6nm8
3/Hy/nmo4n+2k0XoLUC1pPtAWLjlVUbWWoaeP2kJKYDqUmwnhesHJhPPMpDV2mbi
Zs9xnuFqRsZ0tSidZlgeNeCwuo6yC1ERGDsLJ03IVODqSQIDAQABo4GtMIGqMB0G
A1UdDgQWBBS+PM1YI32FywSatPrPPA9lAtWrOjB7BgNVHSMEdDBygBS+PM1YI32F
ywSatPrPPA9lAtWrOqFPpE0wSzELMAkGA1UEBhMCQVQxDTALBgNVBAgTBFdJRU4x
DTALBgNVBAcTBFdpZW4xDDAKBgNVBAoTA0VveDEQMA4GA1UEAxMHdi1tYW5pcIIJ
AI7D9hjVkWY1MAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADggEBAHOdHC3e
68lbsUkxG7kWuEsoiZVYvGjH42X7yvwXtUZrwbxLnNMG/BgUtUmRv3LHpt1W0nHd
wp0wskUQVjphIOptMCQtaNdCa6unLej/9uGTqfOZHQnx4l14k+MgMYe9CNG6Cyv8
BGa3eAoXH7teawoxbphys9qFZFWN7M9gwk3ae9caHKxwgkuq+lpKGUnG7xNfTrqX
AczpR8ODZ2n2wyBT8EiywdXSrsUJpp37KhWzF1HdxqvVp668fmYppMcwSFw7Pr/K
38+EBQXUK/zV5qhMmehOj6qes7bJGO0fq3Fco0a9WHc42RZE2GH/jxa7amq3ei51
sMWq1pM1CEulWJM=
-----END CERTIFICATE-----
EOF

    cat << EOF > "$SP_CERT_FILE"
-----BEGIN CERTIFICATE-----
MIID+jCCAuKgAwIBAgIJAIt//73ym/+bMA0GCSqGSIb3DQEBBQUAMFsxCzAJBgNV
BAYTAkFUMQ8wDQYDVQQIEwZWaWVubmExDzANBgNVBAcTBlZpZW5uYTEMMAoGA1UE
ChMDRU9YMRwwGgYDVQQDExN2LW1hbmlwIFNlcnZpY2UgUHJvMB4XDTEzMTExOTEy
NTk0OVoXDTE2MTExODEyNTk0OVowWzELMAkGA1UEBhMCQVQxDzANBgNVBAgTBlZp
ZW5uYTEPMA0GA1UEBxMGVmllbm5hMQwwCgYDVQQKEwNFT1gxHDAaBgNVBAMTE3Yt
bWFuaXAgU2VydmljZSBQcm8wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQDLF0Fw3a6tTXnthPlLMYtSGiuDlwJYc3qVbKuWONLizLnd/Hkq7qUUdUp2qSnZ
IU3SwYLUZPJWCADOgvVKyKpR27RRyQiLtCVBk4TgkLLRBASAYW4xzD02iaLsp4JZ
8w74GEflGYKxmMB99rHBXGjwFW9KsmjgToRqCJaVK+bSbDb2rtmI69/whnIMUF8x
nHY6O3lvgYp9LOVFLqcEOBo9aLI9RcFA0yx3GRKwjflLXc4q/lpxyuyAG18VfMG6
cqHynXgE2EqD8soTA05nzpbdXwl3eQT8x0I29PfNQoootEX2TRLoqR5GXrDLZd7R
KD8D8FD3UdCCQY4CbxeMrTHDAgMBAAGjgcAwgb0wHQYDVR0OBBYEFFJHTU77zrJP
rRAPGquQ8T6O4uNIMIGNBgNVHSMEgYUwgYKAFFJHTU77zrJPrRAPGquQ8T6O4uNI
oV+kXTBbMQswCQYDVQQGEwJBVDEPMA0GA1UECBMGVmllbm5hMQ8wDQYDVQQHEwZW
aWVubmExDDAKBgNVBAoTA0VPWDEcMBoGA1UEAxMTdi1tYW5pcCBTZXJ2aWNlIFBy
b4IJAIt//73ym/+bMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADggEBAJLK
KWB/wepKXHAKuGN2YwDEIz1oSOzAH2WcArmoRAtjJslK+Yt4RmyDSLZYXCHcHhfK
LFOMENhIh/uXWAJIruuAXljE9kub9P5mS4ldXpy65InN8ktjmZcaiFTBGK+4PSvL
sZcCd5hi9a/NOcNforCgOmf7h3Vbw1v4yclWiCq5FESrzMaU/kKjdBipw/mV/BN0
WHKKHH6IL6TZACPYM6Qw2Z4Vmg1A7X9cUgdljWHyIz5XVazo2G6+e+X8wJRu8ANy
9Weg4YNpBqDdmgj7k+VZHN0KQnKwWP5fo/TFI8QD0LIehoXWDeoy767i9wn+tg7E
7DrJjQLI4lxEkecPwMI=
-----END CERTIFICATE-----
EOF

    cat << EOF > "$SP_CERT_FILE_2"
`cat $SP_CERT_FILE`
EOF

    cat << EOF > "$SP_KEY_FILE"
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAyxdBcN2urU157YT5SzGLUhorg5cCWHN6lWyrljjS4sy53fx5
Ku6lFHVKdqkp2SFN0sGC1GTyVggAzoL1SsiqUdu0UckIi7QlQZOE4JCy0QQEgGFu
Mcw9Nomi7KeCWfMO+BhH5RmCsZjAffaxwVxo8BVvSrJo4E6EagiWlSvm0mw29q7Z
iOvf8IZyDFBfMZx2Ojt5b4GKfSzlRS6nBDgaPWiyPUXBQNMsdxkSsI35S13OKv5a
ccrsgBtfFXzBunKh8p14BNhKg/LKEwNOZ86W3V8Jd3kE/MdCNvT3zUKKKLRF9k0S
6KkeRl6wy2Xe0Sg/A/BQ91HQgkGOAm8XjK0xwwIDAQABAoIBAFaGDOJZ/75jwKt5
uH/ZlsKe1aUVY/FtGW+pwZyZjvcDQ7iYhMLOs1P4+IV/Yo3YC4Db4rI8Y6ZVeIqC
7qAyx6ViVft2C4cBc9HxWG4YF6bG8GgFml3q5rVihCAQ6Y8K53i5V3/6k1y4eGHy
BR8dELQgXa7UPaw6p11JVWYuMwO4RbLhzq1XHvk3db8Mi3MSdGP/tsf8zv3vdz2J
yNZ52JesbL62s9hFlb51a4uBLTjQFvmXQxTn6nDz+d/o1KZexGZDf68mTQ1+Gvp0
Fi4Oi1fC7dq0BDLO1iFQQCL6b6RvzVCGhJQntgaanWYDZqQxO1G2t1n3S6PP2TlO
x52oGNECgYEA+s0q4WeYvmh+AuL37i2lQyPvZhzZBBFChbg6C7RPtgg5zx0YX045
SsH3J/bA5A/BTRF4uaqJuJWUTc1cYqfmYT7X+7YciRSNRUSVdMlZoz8fb9VB0lM3
TeAj+nqGa0twEmqTXPiW1PW1TOJ6u7xn1yi/xxyUkly+GvpPuke6OkkCgYEAz0zr
pOLOFwMCVAR0/1qz4OdVgMEeIezsqe+63iZW9NukJsDBFe4TtNXdA44tybp+lrRC
qaSY0OLLZ1J2Wb5bVvavi5hUtzIQxJaLjQpbYFtABCjG6yg1qVG5Z0i3o/ogH+v2
QDbeoyW6UyvQu/kp/0mSUoYrjik46pvbsM+OK6sCgYEAn+61qYemn8WCldSmxfvV
pzsDLtq2iSF4ik0wtsYFDs+wDaNAJ4Z6gnGuao2v878YRU0e70cRC+RW7kZG46Ku
BtVMZfd7uu6gJ8vUguTjhHZ8VZRopPbsDX0hdFkt3r38ecH8twzPIn6NXroOCinb
DhmuMgrHs43wrMNylBepagECgYBOz9u28FOSBB7aemdQvdctZkXnkYQ3ObAwW2gc
FU9yAB9EbHv8LmtnkPdZ5rAZxcFi4l2FyYIfyFm0inFcZTastVTAKcXrcClX1DRy
BsH+vDJ2YlpeBQeBvARU9Bx9Rxb3i+ovN60lMa7I+Bt/m5cP65Sps0DT53AwIdlA
O2i9yQKBgQCLVAXqkqYtZ530JSXPeEDuBlZa1+5mfg2kTavy+1vy9nvOa1tPxGoV
Vi7zpJDkCTZDV8dEO3Qpf9YPSbZzH0AG2RVtDdg1fZVSu3GDSf8eBkoWr1yH/vVm
+wB7K+hUhEGlHy7FC5g96nUncCMdcNwZTN8E5G/8njGQWKObMAy3tw==
-----END RSA PRIVATE KEY-----
EOF

    cat << EOF > "$SP_KEY_FILE_2"
`cat $SP_KEY_FILE`
EOF


    # Read certificates and keys into variables
    IDP_CERT_CONTENT=`cat $IDP_CERT_FILE | grep -v CERTIFICATE`
    SP_CERT_CONTENT=`cat $SP_CERT_FILE | grep -v CERTIFICATE`
    SP_KEY_CONTENT=`cat $SP_KEY_FILE | grep -v PRIVATE`
    
    echo "Configuring Shibboleth"
    
    ########################################################
    # attribute-map.xml
    ########################################################    
    echo "Creating /etc/shibboleth/attribute-map.xml"
    cat << EOF > /etc/shibboleth/attribute-map.xml
<Attributes xmlns="urn:mace:shibboleth:2.0:attribute-map" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Attribute name="urn:oid:2.5.4.3" id="commonName" />
    <Attribute name="urn:oid:2.5.4.4" id="surname" />
    <Attribute name="urn:oid:0.9.2342.19200300.100.1.1" id="uid" />
</Attributes>
EOF

    ########################################################
    # attribute-policy.xml
    ########################################################    
    echo "Creating /etc/shibboleth/attribute-policy.xml"
    cat << EOF > /etc/shibboleth/attribute-policy.xml
<afp:AttributeFilterPolicyGroup
    xmlns="urn:mace:shibboleth:2.0:afp:mf:basic" xmlns:basic="urn:mace:shibboleth:2.0:afp:mf:basic" xmlns:afp="urn:mace:shibboleth:2.0:afp" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <afp:AttributeFilterPolicy>
        <afp:PolicyRequirementRule xsi:type="ANY"/>
        <afp:AttributeRule attributeID="*">
            <afp:PermitValueRule xsi:type="ANY"/>
        </afp:AttributeRule>
    </afp:AttributeFilterPolicy>
</afp:AttributeFilterPolicyGroup>
EOF

    ########################################################
    # idp-metadata.xml
    ########################################################    
    echo "Creating /etc/shibboleth/idp-metadata.xml"
    cat << EOF > /etc/shibboleth/idp-metadata.xml
<EntityDescriptor entityID="$IDP_ENTITYID" validUntil="2030-01-01T00:00:00Z"
                  xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
                  xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                  xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <IDPSSODescriptor protocolSupportEnumeration="urn:mace:shibboleth:1.0 urn:oasis:names:tc:SAML:1.1:protocol urn:oasis:names:tc:SAML:2.0:protocol">

        <Extensions>
            <shibmd:Scope regexp="false">$HOST_EXTENSION</shibmd:Scope>
        </Extensions>

        <KeyDescriptor>
            <ds:KeyInfo>
                <ds:X509Data>
                    <ds:X509Certificate>
$IDP_CERT_CONTENT
                    </ds:X509Certificate>
                </ds:X509Data>
            </ds:KeyInfo>
        </KeyDescriptor>

        <ArtifactResolutionService Binding="urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding" Location="https://$IDP_HOST:$IDP_SOAP/idp/profile/SAML1/SOAP/ArtifactResolution" index="1"/>

        <ArtifactResolutionService Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP" Location="https://$IDP_HOST:$IDP_SOAP/idp/profile/SAML2/SOAP/ArtifactResolution" index="2"/>

        <NameIDFormat>urn:mace:shibboleth:1.0:nameIdentifier</NameIDFormat>
        <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</NameIDFormat>

        <SingleSignOnService Binding="urn:mace:shibboleth:1.0:profiles:AuthnRequest" Location="https://$IDP_HOST:$IDP_PORT/idp/profile/Shibboleth/SSO" />

        <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://$IDP_HOST:$IDP_PORT/idp/profile/SAML2/Redirect/SSO" />

        <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://$IDP_HOST:$IDP_PORT/idp/profile/SAML2/Redirect/SLO" ResponseLocation="https://$IDP_HOST:$IDP_PORT/idp/profile/SAML2/Redirect/SLO"/>
    </IDPSSODescriptor>

    <AttributeAuthorityDescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:1.1:protocol urn:oasis:names:tc:SAML:2.0:protocol">

        <Extensions>
            <shibmd:Scope regexp="false">$HOST_EXTENSION</shibmd:Scope>
        </Extensions>

        <KeyDescriptor>
            <ds:KeyInfo>
                <ds:X509Data>
                    <ds:X509Certificate>
$IDP_CERT_CONTENT
                    </ds:X509Certificate>
                </ds:X509Data>
            </ds:KeyInfo>
        </KeyDescriptor>

        <AttributeService Binding="urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding" Location="https://$IDP_HOST:$IDP_SOAP/idp/profile/SAML1/SOAP/AttributeQuery" />

        <AttributeService Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP" Location="https://$IDP_HOST:$IDP_SOAP/idp/profile/SAML2/SOAP/AttributeQuery" />        

        <NameIDFormat>urn:mace:shibboleth:1.0:nameIdentifier</NameIDFormat>
        <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</NameIDFormat>
    </AttributeAuthorityDescriptor>
</EntityDescriptor>
EOF

    ########################################################
    # shibboleth2.xml
    ########################################################    
    echo "Creating /etc/shibboleth/sp-shibboleth2.xml"
    cat << EOF > /etc/shibboleth/shibboleth2.xml
<SPConfig xmlns="urn:mace:shibboleth:2.0:native:sp:config"
    xmlns:conf="urn:mace:shibboleth:2.0:native:sp:config"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"    
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    logger="syslog.logger" clockSkew="7600">

    <!-- The OutOfProcess section contains properties affecting the shibd daemon. -->
    <OutOfProcess logger="shibd.logger">
        <!--
        <Extensions>
            <Library path="odbc-store.so" fatal="true"/>
        </Extensions>
        -->
    </OutOfProcess>
    
    <!-- Only one listener can be defined, to connect in-process modules to shibd. -->
    <UnixListener address="shibd.sock"/>
    <!-- <TCPListener address="127.0.0.1" port="1600" acl="127.0.0.1"/> -->
    
    <!-- This set of components stores sessions and other persistent data in daemon memory. -->
    <StorageService type="Memory" id="mem" cleanupInterval="900"/>
    <SessionCache type="StorageService" StorageService="mem" cacheAssertions="false"
                  cacheAllowance="900" inprocTimeout="900" cleanupInterval="900"/>
    <ReplayCache StorageService="mem"/>
    <ArtifactMap artifactTTL="180"/>

    <!-- This set of components stores sessions and other persistent data in an ODBC database. -->
    <!--
    <StorageService type="ODBC" id="db" cleanupInterval="900">
        <ConnectionString>
        DRIVER=drivername;SERVER=dbserver;UID=shibboleth;PWD=password;DATABASE=shibboleth;APP=Shibboleth
        </ConnectionString>
    </StorageService>
    <SessionCache type="StorageService" StorageService="db" cacheAssertions="false"
                  cacheTimeout="3600" inprocTimeout="900" cleanupInterval="900"/>
    <ReplayCache StorageService="db"/>
    <ArtifactMap StorageService="db" artifactTTL="180"/>
    -->

    <!--
    To customize behavior for specific resources on Apache, and to link vhosts or
    resources to ApplicationOverride settings below, use web server options/commands.
    See https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPConfigurationElements for help.
    
    For examples with the RequestMap XML syntax instead, see the example-shibboleth2.xml
    file, and the https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapHowTo topic.
    -->
    <RequestMapper type="Native">
        <RequestMap>
            <!--
            The example requires a session for documents in $PROTECTED_DIR on the containing host with http and
            https on the default ports. Note that the name and port in the <Host> elements MUST match
            Apache's ServerName and Port directives or the IIS Site name in the <ISAPI> element above.
            -->
            <Host name="$SP_HOST">
                <Path name="$PROTECTED_DIR" authType="shibboleth" requireSession="true"/>
            </Host>
        </RequestMap>
    </RequestMapper>

    <!--
    The ApplicationDefaults element is where most of Shibboleth's SAML bits are defined.
    Resource requests are mapped by the RequestMapper to an applicationId that
    points into to this section (or to the defaults here).
    -->
    <ApplicationDefaults entityID="https://$SP_HOST/shibboleth"
                         REMOTE_USER="eppn persistent-id targeted-id"
                         metadataAttributePrefix="Meta-"
                         signing="false" encryption="false">

        <!--
        Controls session lifetimes, address checks, cookie handling, and the protocol handlers.
        You MUST supply an effectively unique handlerURL value for each of your applications.
        The value defaults to /Shibboleth.sso, and should be a relative path, with the SP computing
        a relative value based on the virtual host. Using handlerSSL="true", the default, will force
        the protocol to be https. You should also set cookieProps to "https" for SSL-only sites.
        Note that while we default checkAddress to "false", this has a negative impact on the
        security of your site. Stealing sessions via cookie theft is much easier with this disabled.
        -->
        <Sessions lifetime="7200" timeout="3600" checkAddress="false"
            handlerURL="/Shibboleth.sso" handlerSSL="false" cookieProps="http" relayState="ss:mem"
            exportLocation="http://localhost/Shibboleth.sso/GetAssertion" exportACL="127.0.0.1"
            idpHistory="false" idpHistoryDays="7">

            <!--
            The "stripped down" files use the shorthand syntax for configuring handlers.
            This uses the old "every handler specified directly" syntax. You can replace
            or supplement the new syntax following these examples.
            -->
          
            <!--
            SessionInitiators handle session requests and relay them to a Discovery page,
            or to an IdP if possible. Automatic session setup will use the default or first
            element (or requireSessionWith can specify a specific id to use).
            -->

            <SessionInitiator type="SAML2" entityID="$IDP_ENTITYID" forceAuthn="false" Location="/Login" template="/etc/shibboleth/bindingTemplate.html"/>

            <!--
            md:AssertionConsumerService locations handle specific SSO protocol bindings,
            such as SAML 2.0 POST or SAML 1.1 Artifact. The isDefault and index attributes
            are used when sessions are initiated to determine how to tell the IdP where and
            how to return the response.
            -->
        
            <md:AssertionConsumerService Location="/SAML2/POST" index="1"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/>
            <md:AssertionConsumerService Location="/SAML2/POST-SimpleSign" index="2"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign"/>
            <md:AssertionConsumerService Location="/SAML2/Artifact" index="3"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"/>
            <md:AssertionConsumerService Location="/SAML2/ECP" index="4"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:PAOS"/>
            <md:AssertionConsumerService Location="/SAML/POST" index="5"
                Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post"/>
            <md:AssertionConsumerService Location="/SAML/Artifact" index="6"
                Binding="urn:oasis:names:tc:SAML:1.0:profiles:artifact-01"/>
            
            <!-- LogoutInitiators enable SP-initiated local or global/single logout of sessions. -->
            <LogoutInitiator type="Local" Location="/Logout" template="/etc/shibboleth/bindingTemplate.html" />
            <LogoutInitiator type="SAML2" Location="/SLogout" template="/etc/shibboleth/bindingTemplate.html" />
            
            <!-- md:SingleLogoutService locations handle single logout (SLO) protocol messages. -->
            <md:SingleLogoutService Location="/SLO/SOAP"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"/>
            <md:SingleLogoutService Location="/SLO/Redirect" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"/>
            <md:SingleLogoutService Location="/SLO/POST" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/>
            <md:SingleLogoutService Location="/SLO/Artifact" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"/>

            <!-- md:ManageNameIDService locations handle NameID management (NIM) protocol messages. -->
            <md:ManageNameIDService Location="/NIM/SOAP"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"/>
            <md:ManageNameIDService Location="/NIM/Redirect" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"/>
            <md:ManageNameIDService Location="/NIM/POST" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/>
            <md:ManageNameIDService Location="/NIM/Artifact" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"/>

            <!--
            md:ArtifactResolutionService locations resolve artifacts issued when using the
            SAML 2.0 HTTP-Artifact binding on outgoing messages, generally uses SOAP.
            -->
            <md:ArtifactResolutionService Location="/Artifact/SOAP" index="1"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"/>

            <!-- Extension service that generates "approximate" metadata based on SP configuration. -->
            <Handler type="MetadataGenerator" Location="/Metadata" signing="false"/>

            <!-- Status reporting service. -->
            <Handler type="Status" Location="/Status" acl="127.0.0.1 ::1"/>

            <!-- Session diagnostic service. -->
            <Handler type="Session" Location="/Session" showAttributeValues="false"/>

            <!-- JSON feed of discovery information. -->
            <Handler type="DiscoveryFeed" Location="/DiscoFeed"/>
        </Sessions>

        <!--
        Allows overriding of error template information/filenames. You can
        also add attributes with values that can be plugged into the templates.
        -->
        <Errors session="/etc/shibboleth/sessionError.html" metadata="/etc/shibboleth/metadataError.html" access="/etc/shibboleth/accessError.html" ssl="/etc/shibboleth/sslError.html" supportContact="webmaster@eox.at" logoLocation="/shibboleth-sp/logo.jpg" styleSheet="/shibboleth-sp/main.css" globalLogout="/etc/shibboleth/globalLogout.html" localLogout="/etc/shibboleth/localLogout.html"></Errors>
      
        <!--
        Uncomment and modify to tweak settings for specific IdPs or groups. Settings here
        generally match those allowed by the <ApplicationDefaults> element.
        -->
        <RelyingParty Name="$IDP_ENTITYID/shibboleth" keyName="defcreds"/>

        <MetadataProvider type="Chaining">
            <MetadataProvider type="XML" file="/etc/shibboleth/idp-metadata.xml"/>
            <MetadataProvider type="XML" file="/etc/shibboleth/sp-metadata.xml"/>
        </MetadataProvider>

        <!-- TrustEngines run in order to evaluate peer keys and certificates. -->
        <TrustEngine type="Chaining">
            <TrustEngine type="ExplicitKey"/>
            <TrustEngine type="PKIX"/>
        </TrustEngine>

        <!-- Map to extract attributes from SAML assertions. -->
        <AttributeExtractor type="XML" validate="true" reloadChanges="false" path="attribute-map.xml"/>

        <!-- Extracts support information for IdP from its metadata. -->
        <AttributeExtractor type="Metadata" errorURL="errorURL" DisplayName="displayName"/>

        <!-- Use a SAML query if no attributes are supplied during SSO. -->
        <AttributeResolver type="Query" subjectMatch="true"/>

        <!-- Default filtering policy for recognized attributes, lets other data pass. -->
        <AttributeFilter type="XML" validate="true" path="attribute-policy.xml"/>

        <!-- Simple file-based resolver for using a single keypair. -->
        <CredentialResolver type="File" key="/etc/shibboleth/sp-key.pem" certificate="/etc/shibboleth/sp-cert.pem" keyName="defcreds"/>
        <!--
        The default settings can be overridden by creating ApplicationOverride elements (see
        the https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApplicationOverride topic).
        Resource requests are mapped by web server commands, or the RequestMapper, to an
        applicationId setting.
        
        Example of a second application (for a second vhost) that has a different entityID.
        Resources on the vhost would map to an applicationId of "admin":
        -->
        <!--
        <ApplicationOverride id="admin" entityID="https://admin.example.org/shibboleth"/>
        -->
    </ApplicationDefaults>
    
    <!-- Policies that determine how to process and authenticate runtime messages. -->
    <SecurityPolicyProvider type="XML" validate="true" path="security-policy.xml"/>

    <!-- Low-level configuration about protocols and bindings available for use. -->
    <ProtocolProvider type="XML" validate="true" reloadChanges="false" path="protocols.xml"/>

</SPConfig>
EOF

    ########################################################
    # sp-metadata.xml
    ########################################################
    echo "Creating /etc/shibboleth/sp-metadata.xml"  
    cat << EOF > /etc/shibboleth/sp-metadata.xml
<EntityDescriptor entityID="$SP_ENTITYID" validUntil="2030-01-01T00:00:00Z"
                  xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
                  xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                  xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <KeyDescriptor>
            <ds:KeyInfo>
                <ds:X509Data>
                    <ds:X509Certificate>
$SP_CERT_CONTENT
                    </ds:X509Certificate>
                </ds:X509Data>
            </ds:KeyInfo>
        </KeyDescriptor>

        <!-- This tells IdPs that Single Logout is supported and where/how to request it. -->
        <SingleLogoutService
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
            Location="https://$SP_HOST/Shibboleth.sso/SLO/SOAP" xmlns="urn:oasis:names:tc:SAML:2.0:metadata"/>
        <SingleLogoutService
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
            Location="https://$SP_HOST/Shibboleth.sso/SLO/Redirect" xmlns="urn:oasis:names:tc:SAML:2.0:metadata"/>
        <SingleLogoutService
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
            Location="https://$SP_HOST/Shibboleth.sso/SLO/POST" xmlns="urn:oasis:names:tc:SAML:2.0:metadata"/>
        <SingleLogoutService
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"
            Location="https://$SP_HOST/Shibboleth.sso/SLO/Artifact" xmlns="urn:oasis:names:tc:SAML:2.0:metadata"/>

        <!--
    		This tells IdPs where and how to push assertions through the browser. Mostly
    		the SP will tell the IdP what location to use in its request, but this
    		is how the IdP validates the location and also figures out which
    		SAML version/binding to use.
    		-->

        <AssertionConsumerService
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
            Location="https://$SP_HOST/Shibboleth.sso/SAML2/POST"
            index="1" isDefault="true" xmlns="urn:oasis:names:tc:SAML:2.0:metadata"/>
        <AssertionConsumerService
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign"
            Location="https://$SP_HOST/Shibboleth.sso/SAML2/POST-SimpleSign"
            index="2" xmlns="urn:oasis:names:tc:SAML:2.0:metadata"/>
        <AssertionConsumerService
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"
            Location="https://$SP_HOST/Shibboleth.sso/SAML2/Artifact"
            index="3" xmlns="urn:oasis:names:tc:SAML:2.0:metadata"/>
        <AssertionConsumerService
            Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post"
            Location="https://$SP_HOST/Shibboleth.sso/SAML/POST"
            index="4" xmlns="urn:oasis:names:tc:SAML:2.0:metadata"/>
        <AssertionConsumerService
            Binding="urn:oasis:names:tc:SAML:1.0:profiles:artifact-01"
            Location="https://$SP_HOST/Shibboleth.sso/SAML/Artifact"
            index="5" xmlns="urn:oasis:names:tc:SAML:2.0:metadata"/>
        
        <!-- This tells IdPs that you only need transient identifiers. -->
        <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</NameIDFormat>
        
    </SPSSODescriptor>

    <Organization>
        <OrganizationName xml:lang="en">$SP_NAME</OrganizationName>
        <OrganizationDisplayName xml:lang="en">$SP_ORG_DISP_NAME</OrganizationDisplayName>
        <OrganizationURL xml:lang="en">$SP_HOME_FULL_URL</OrganizationURL>
    </Organization>
</EntityDescriptor>
EOF

    ########################################################
    # relying-party.xml
    ########################################################    
    echo "Creating /etc/shibboleth/relying-party.xml"
    cat << EOF > /etc/shibboleth/relying-party.xml
<?xml version="1.0" encoding="UTF-8"?>

<rp:RelyingPartyGroup xmlns:rp="urn:mace:shibboleth:2.0:relying-party"
                   xmlns:saml="urn:mace:shibboleth:2.0:relying-party:saml"
                   xmlns:metadata="urn:mace:shibboleth:2.0:metadata"
                   xmlns:resource="urn:mace:shibboleth:2.0:resource"
                   xmlns:security="urn:mace:shibboleth:2.0:security"
                   xmlns:samlsec="urn:mace:shibboleth:2.0:security:saml"
                   xmlns:samlmd="urn:oasis:names:tc:SAML:2.0:metadata"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xsi:schemaLocation="urn:mace:shibboleth:2.0:relying-party classpath:/schema/shibboleth-2.0-relying-party.xsd
                                       urn:mace:shibboleth:2.0:relying-party:saml classpath:/schema/shibboleth-2.0-relying-party-saml.xsd
                                       urn:mace:shibboleth:2.0:metadata classpath:/schema/shibboleth-2.0-metadata.xsd
                                       urn:mace:shibboleth:2.0:resource classpath:/schema/shibboleth-2.0-resource.xsd
                                       urn:mace:shibboleth:2.0:security classpath:/schema/shibboleth-2.0-security.xsd
                                       urn:mace:shibboleth:2.0:security:saml classpath:/schema/shibboleth-2.0-security-policy-saml.xsd
                                       urn:oasis:names:tc:SAML:2.0:metadata classpath:/schema/saml-schema-metadata-2.0.xsd">
                                       
    <!-- ========================================== -->
    <!--      Relying Party Configurations          -->
    <!-- ========================================== -->
    <rp:AnonymousRelyingParty provider="https://$IDP_HOST/shibboleth"
                           defaultSigningCredentialRef="IdPCredential" />
    
    <rp:DefaultRelyingParty provider="https://$IDP_HOST/shibboleth"
                         defaultSigningCredentialRef="IdPCredential">
        <!-- 
            Each attribute in these profiles configuration is set to its default value,
            that is, the values that would be in effect if those attributes were not present.
            We list them here so that people are aware of them (since they seem reluctant to 
            read the documentation).
        -->
        <rp:ProfileConfiguration xsi:type="saml:ShibbolethSSOProfile" 
                              includeAttributeStatement="false"
                              assertionLifetime="PT5M"
                              signResponses="conditional"
                              signAssertions="never" />
                              
        <rp:ProfileConfiguration xsi:type="saml:SAML1AttributeQueryProfile"
                              assertionLifetime="PT5M"
                              signResponses="conditional"
                              signAssertions="never" />
        
        <rp:ProfileConfiguration xsi:type="saml:SAML1ArtifactResolutionProfile"
                              signResponses="conditional"
                              signAssertions="never" />
        
        <rp:ProfileConfiguration xsi:type="saml:SAML2SSOProfile" 
                              includeAttributeStatement="true"
                              assertionLifetime="PT5M"
                              assertionProxyCount="0" 
                              signResponses="never"
                              signAssertions="always" 
                              encryptAssertions="conditional"
                              encryptNameIds="never" />

        <rp:ProfileConfiguration xsi:type="saml:SAML2ECPProfile"
                              includeAttributeStatement="true"
                              assertionLifetime="PT5M"
                              assertionProxyCount="0"
                              signResponses="never"
                              signAssertions="always"
                              encryptAssertions="conditional"
                              encryptNameIds="never" />

        <rp:ProfileConfiguration xsi:type="saml:SAML2AttributeQueryProfile" 
                              assertionLifetime="PT5M"
                              assertionProxyCount="0" 
                              signResponses="conditional"
                              signAssertions="never"
                              encryptAssertions="conditional"
                              encryptNameIds="never" />
        
        <rp:ProfileConfiguration xsi:type="saml:SAML2ArtifactResolutionProfile" 
                              signResponses="never"
                              signAssertions="always"
                              encryptAssertions="conditional"
                              encryptNameIds="never"/>
        
    </rp:DefaultRelyingParty>
        
    
    <!-- ========================================== -->
    <!--      Metadata Configuration                -->
    <!-- ========================================== -->
    <!-- MetadataProvider the combining other MetadataProviders -->
    <metadata:MetadataProvider id="ShibbolethMetadata" xsi:type="metadata:ChainingMetadataProvider">
    
    	<!-- Load the IdP's own metadata.  This is necessary for artifact support. -->
        <metadata:MetadataProvider id="IdPMD" xsi:type="metadata:ResourceBackedMetadataProvider">
            <metadata:MetadataResource xsi:type="resource:FilesystemResource" file="/opt/shibboleth-idp/metadata/idp-metadata.xml" />
        </metadata:MetadataProvider>
	
	<!-- Load the SP's metadata.  -->
	<metadata:MetadataProvider xsi:type="FilesystemMetadataProvider" xmlns="urn:mace:shibboleth:2.0:metadata" id="SPMETADATA" metadataFile="/opt/shibboleth-idp/metadata/sp-metadata.xml" />
        
        <!-- Example metadata provider. -->
        <!-- Reads metadata from a URL and store a backup copy on the file system. -->
        <!-- Validates the signature of the metadata and filters out all by SP entities in order to save memory -->
        <!-- To use: fill in 'metadataURL' and 'backingFile' properties on MetadataResource element -->
        <!--
        <metadata:MetadataProvider id="URLMD" xsi:type="metadata:FileBackedHTTPMetadataProvider"
                          metadataURL="http://example.org/metadata.xml"
                          backingFile="/opt/shibboleth-idp/metadata/some-metadata.xml">
            <metadata:MetadataFilter xsi:type="metadata:ChainingFilter">
                <metadata:MetadataFilter xsi:type="metadata:RequiredValidUntil" 
                                maxValidityInterval="P7D" />
                <metadata:MetadataFilter xsi:type="metadata:SignatureValidation"
                                trustEngineRef="shibboleth.MetadataTrustEngine"
                                requireSignedMetadata="true" />
	            <metadata:MetadataFilter xsi:type="metadata:EntityRoleWhiteList">
                    <metadata:RetainedRole>samlmd:SPSSODescriptor</metadata:RetainedRole>
                </metadata:MetadataFilter>
            </metadata:MetadataFilter>
        </metadata:MetadataProvider>
        -->
        
    </metadata:MetadataProvider>

    
    <!-- ========================================== -->
    <!--     Security Configurations                -->
    <!-- ========================================== -->
    <security:Credential id="IdPCredential" xsi:type="security:X509Filesystem">
        <security:PrivateKey>/opt/shibboleth-idp/credentials/idp-key.pem</security:PrivateKey>
        <security:Certificate>/opt/shibboleth-idp/credentials/idp-cert.pem</security:Certificate>
    </security:Credential>
    
    <!-- Trust engine used to evaluate the signature on loaded metadata. -->
    <!--
    <security:TrustEngine id="shibboleth.MetadataTrustEngine" xsi:type="security:StaticExplicitKeySignature">
        <security:Credential id="MyFederation1Credentials" xsi:type="security:X509Filesystem">
            <security:Certificate>/opt/shibboleth-idp/credentials/federation1.crt</security:Certificate>
        </security:Credential>
    </security:TrustEngine>
     -->
     
    <!-- DO NOT EDIT BELOW THIS POINT -->
    <!-- 
        The following trust engines and rules control every aspect of security related to incoming messages. 
        Trust engines evaluate various tokens (like digital signatures) for trust worthiness while the 
        security policies establish a set of checks that an incoming message must pass in order to be considered
        secure.  Naturally some of these checks require the validation of the tokens evaluated by the trust 
        engines and so you'll see some rules that reference the declared trust engines.
    -->
    <security:TrustEngine id="shibboleth.SignatureTrustEngine" xsi:type="security:SignatureChaining">
        <security:TrustEngine id="shibboleth.SignatureMetadataExplicitKeyTrustEngine" xsi:type="security:MetadataExplicitKeySignature"
                              metadataProviderRef="ShibbolethMetadata" />                              
        <security:TrustEngine id="shibboleth.SignatureMetadataPKIXTrustEngine" xsi:type="security:MetadataPKIXSignature"
                              metadataProviderRef="ShibbolethMetadata" />
    </security:TrustEngine>
    
    <security:TrustEngine id="shibboleth.CredentialTrustEngine" xsi:type="security:Chaining">
        <security:TrustEngine id="shibboleth.CredentialMetadataExplictKeyTrustEngine" xsi:type="security:MetadataExplicitKey"
                              metadataProviderRef="ShibbolethMetadata" />
        <security:TrustEngine id="shibboleth.CredentialMetadataPKIXTrustEngine" xsi:type="security:MetadataPKIXX509Credential"
                              metadataProviderRef="ShibbolethMetadata" />
    </security:TrustEngine>
     
    <security:SecurityPolicy id="shibboleth.ShibbolethSSOSecurityPolicy" xsi:type="security:SecurityPolicyType">
        <security:Rule xsi:type="samlsec:Replay" required="false" />
        <security:Rule xsi:type="samlsec:IssueInstant" required="false"/>
        <security:Rule xsi:type="samlsec:MandatoryIssuer"/>
    </security:SecurityPolicy>
    
    <security:SecurityPolicy id="shibboleth.SAML1AttributeQuerySecurityPolicy" xsi:type="security:SecurityPolicyType">
        <security:Rule xsi:type="samlsec:Replay"/>
        <security:Rule xsi:type="samlsec:IssueInstant"/>
        <security:Rule xsi:type="samlsec:ProtocolWithXMLSignature" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="security:ClientCertAuth" trustEngineRef="shibboleth.CredentialTrustEngine" />
        <security:Rule xsi:type="samlsec:MandatoryIssuer"/>
        <security:Rule xsi:type="security:MandatoryMessageAuthentication" />
    </security:SecurityPolicy>
    
    <security:SecurityPolicy id="shibboleth.SAML1ArtifactResolutionSecurityPolicy" xsi:type="security:SecurityPolicyType">
        <security:Rule xsi:type="samlsec:Replay"/>
        <security:Rule xsi:type="samlsec:IssueInstant"/>
        <security:Rule xsi:type="samlsec:ProtocolWithXMLSignature" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="security:ClientCertAuth" trustEngineRef="shibboleth.CredentialTrustEngine" />
        <security:Rule xsi:type="samlsec:MandatoryIssuer"/>
        <security:Rule xsi:type="security:MandatoryMessageAuthentication" />
    </security:SecurityPolicy>

    <security:SecurityPolicy id="shibboleth.SAML2SSOSecurityPolicy" xsi:type="security:SecurityPolicyType">
        <security:Rule xsi:type="samlsec:Replay"/>
        <security:Rule xsi:type="samlsec:IssueInstant"/>
        <security:Rule xsi:type="samlsec:SAML2AuthnRequestsSigned"/>
        <security:Rule xsi:type="samlsec:ProtocolWithXMLSignature" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="samlsec:SAML2HTTPRedirectSimpleSign" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="samlsec:SAML2HTTPPostSimpleSign" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="samlsec:MandatoryIssuer"/>
    </security:SecurityPolicy>

    <security:SecurityPolicy id="shibboleth.SAML2AttributeQuerySecurityPolicy" xsi:type="security:SecurityPolicyType">
        <security:Rule xsi:type="samlsec:Replay"/>
        <security:Rule xsi:type="samlsec:IssueInstant"/>
        <security:Rule xsi:type="samlsec:ProtocolWithXMLSignature" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="samlsec:SAML2HTTPRedirectSimpleSign" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="samlsec:SAML2HTTPPostSimpleSign" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="security:ClientCertAuth" trustEngineRef="shibboleth.CredentialTrustEngine" />
        <security:Rule xsi:type="samlsec:MandatoryIssuer"/>
        <security:Rule xsi:type="security:MandatoryMessageAuthentication" />
    </security:SecurityPolicy>
    
    <security:SecurityPolicy id="shibboleth.SAML2ArtifactResolutionSecurityPolicy" xsi:type="security:SecurityPolicyType">
        <security:Rule xsi:type="samlsec:Replay"/>
        <security:Rule xsi:type="samlsec:IssueInstant"/>
        <security:Rule xsi:type="samlsec:ProtocolWithXMLSignature" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="samlsec:SAML2HTTPRedirectSimpleSign" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="samlsec:SAML2HTTPPostSimpleSign" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="security:ClientCertAuth" trustEngineRef="shibboleth.CredentialTrustEngine" />
        <security:Rule xsi:type="samlsec:MandatoryIssuer"/>
        <security:Rule xsi:type="security:MandatoryMessageAuthentication" />
    </security:SecurityPolicy>
    
    <security:SecurityPolicy id="shibboleth.SAML2SLOSecurityPolicy" xsi:type="security:SecurityPolicyType">
        <security:Rule xsi:type="samlsec:Replay"/>
        <security:Rule xsi:type="samlsec:IssueInstant"/>
        <security:Rule xsi:type="samlsec:ProtocolWithXMLSignature" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="samlsec:SAML2HTTPRedirectSimpleSign" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="samlsec:SAML2HTTPPostSimpleSign" trustEngineRef="shibboleth.SignatureTrustEngine" />
        <security:Rule xsi:type="security:ClientCertAuth" trustEngineRef="shibboleth.CredentialTrustEngine" />
        <security:Rule xsi:type="samlsec:MandatoryIssuer"/>
        <security:Rule xsi:type="security:MandatoryMessageAuthentication" />
    </security:SecurityPolicy>
    
</rp:RelyingPartyGroup>
EOF

    ########################################################
    # shib.conf
    ########################################################
    echo "Creating /etc/httpd/conf.d/shib.conf"       
    # mod_shib configuration
    cat << EOF > /etc/httpd/conf.d/shib.conf
# https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApacheConfig

# RPM installations on platforms with a conf.d directory will
# result in this file being copied into that directory for you
# and preserved across upgrades.

# For non-RPM installs, you should copy the relevant contents of
# this file to a configuration location you control.

#
# Load the Shibboleth module.
#
LoadModule mod_shib /usr/lib64/shibboleth/mod_shib_22.so

#
# Ensures handler will be accessible.
#
<Location /Shibboleth.sso>
  Satisfy Any
  Allow from all
</Location>

#
# Used for example style sheet in error templates.
#
<IfModule mod_alias.c>
  <Location /shibboleth-sp>
    Satisfy Any
    Allow from all
  </Location>
  Alias /shibboleth-sp/main.css /usr/share/shibboleth/main.css
</IfModule>

#
# Configure the module for content.
#
# You MUST enable AuthType shibboleth for the module to process
# any requests, and there MUST be a require command as well. To
# enable Shibboleth but not specify any session/access requirements
# use "require shibboleth".
#
<Location $PROTECTED_DIR>
  AuthType shibboleth
  ShibRequestSetting requireSession 1
  require valid-user
</Location>
EOF

    # Restart the shibboleth daemon
    service shibd stop
    service httpd restart
    service shibd start
    
    #Permanently start memcached service
    chkconfig memcached on
    service memcached restart
 
    echo "Done installing Shibboleth"
  else
      echo "Skipped Shibboleth installation"
  fi
  # END Shibboleth Installation
