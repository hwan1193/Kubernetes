# Kubernetes

Elasticsearch Kibana 설치 및 YAML 파일 설정

##
## 1. 패키지 목록 업데이트 (최신 상태로 만듦)
sudo apt update

## 2. HTTPS 연결을 위한 APT 지원, 인증서 검증, 파일 다운로드 도구 설치
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
## - apt-transport-https: APT가 HTTPS로 패키지를 받을 수 있게 해줌
## - ca-certificates: 보안 인증서를 검증하는 데 필요
## - curl: 웹에서 파일 다운로드하는 명령어
## - gnupg: 패키지 서명(GPG 키) 검증 도구
## - lsb-release: 리눅스 버전 정보 확인 도구
## - -y: 설치 중 "확인" 없이 자동 진행

## 3. Elasticsearch 공식 GPG 키를 다운로드하고 시스템에 저장 (패키지 신뢰성 검증용)
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
## -fsSL 옵션:
## -f: 실패 시 조용히 실패
## -s: 진행 상황 숨김
## -S: 오류 시 출력
## -L: 리다이렉트 따라가기

## 4. Elasticsearch 설치를 위한 패키지 저장소를 시스템에 등록
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
## - Elasticsearch 8.x 버전 저장소 추가
## - 저장소 서명 확인을 위해 GPG 키 파일 지정
## - tee 명령어로 내용을 파일에 저장

## 5. 새로 추가한 Elasticsearch 저장소 포함해서 다시 패키지 목록 업데이트
sudo apt update
## - 저장소에 등록된 최신 패키지 목록을 받아옴

## 6. Elasticsearch 설치
sudo apt install elasticsearch -y
## - Elasticsearch 서버 설치
## - -y: 자동으로 설치 진행

## 7. Elasticsearch 설정 파일 수정 (클러스터 이름, 네트워크 설정 등)
sudo nano /etc/elasticsearch/elasticsearch.yml
## - Elasticsearch의 기본 설정 파일을 열어 편집
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -i
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

sudo apt install kibana -y
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system -i
sudo /usr/share/elasticsearch/bin/elasticsearch-certutil cert --name kibana --pem --self-signed
sudo unzip /usr/share/elasticsearch/certificate-bundle.zip -d kibana_certs
sudo mkdir -p /etc/kibana/certs
sudo mv kibana_certs/kibana/kibana.crt /etc/kibana/certs/
sudo mv kibana_certs/kibana/kibana.key /etc/kibana/certs/
sudo mv kibana_certs/ca/ca.crt /etc/kibana/certs/
sudo nano /etc/kibana/kibana.yml
sudo systemctl enable kibana
sudo systemctl start kibana

```bash
root@voidtrace:~# cat /etc/kibana/kibana.yml
## For more configuration options see the configuration guide for Kibana in
## https://www.elastic.co/guide/index.html

## =================== System: Kibana Server ===================
## Kibana is served by a back end server. This setting specifies the port to use.
server.port: 5601

## Specifies the address to which the Kibana server will bind. IP addresses and host names are both valid values.
## The default is 'localhost', which usually means remote machines will not be able to connect.
## To allow connections from remote users, set this parameter to a non-loopback address.
server.host: "0.0.0.0"

## Enables you to specify a path to mount Kibana at if you are running behind a proxy.
## Use the `server.rewriteBasePath` setting to tell Kibana if it should remove the basePath
## from requests it receives, and to prevent a deprecation warning at startup.
## This setting cannot end in a slash.
#server.basePath: ""

## Specifies whether Kibana should rewrite requests that are prefixed with
## `server.basePath` or require that they are rewritten by your reverse proxy.
## Defaults to `false`.
#server.rewriteBasePath: false

## Specifies the public URL at which Kibana is available for end users. If
## `server.basePath` is configured this URL should end with the same basePath.
#server.publicBaseUrl: ""

## The maximum payload size in bytes for incoming server requests.
#server.maxPayload: 1048576

## The Kibana server's name. This is used for display purposes.
#server.name: "your-hostname"

## =================== System: Kibana Server (Optional) ===================
## Enables SSL and paths to the PEM-format SSL certificate and SSL key files, respectively.
## These settings enable SSL for outgoing requests from the Kibana server to the browser.
server.ssl.enabled: true
server.ssl.certificate: /etc/kibana/certs/kibana.crt
server.ssl.key: /etc/kibana/certs/kibana.key

## =================== System: Elasticsearch ===================
## The URLs of the Elasticsearch instances to use for all your queries.
elasticsearch.hosts: ["https://10.0.1.6:9200"]

## If your Elasticsearch is protected with basic authentication, these settings provide
## the username and password that the Kibana server uses to perform maintenance on the Kibana
## index at startup. Your Kibana users still need to authenticate with Elasticsearch, which
## is proxied through the Kibana server.
elasticsearch.username: "kibana_system"
elasticsearch.password: "voidtrace!@#"

## Kibana can also authenticate to Elasticsearch via "service account tokens".
## Service account tokens are Bearer style tokens that replace the traditional username/password based configuration.
## Use this token instead of a username/password.
## elasticsearch.serviceAccountToken: "my_token"

## Time in milliseconds to wait for Elasticsearch to respond to pings. Defaults to the value of
## the elasticsearch.requestTimeout setting.
#elasticsearch.pingTimeout: 1500

## Time in milliseconds to wait for responses from the back end or Elasticsearch. This value
## must be a positive integer.
#elasticsearch.requestTimeout: 30000

## The maximum number of sockets that can be used for communications with elasticsearch.
## Defaults to `800`.
#elasticsearch.maxSockets: 1024

## Specifies whether Kibana should use compression for communications with elasticsearch
## Defaults to `false`.
#elasticsearch.compression: false

## List of Kibana client-side headers to send to Elasticsearch. To send *no* client-side
## headers, set this value to [] (an empty list).
#elasticsearch.requestHeadersWhitelist: [ authorization ]

## Header names and values that are sent to Elasticsearch. Any custom headers cannot be overwritten
## by client-side headers, regardless of the elasticsearch.requestHeadersWhitelist configuration.
#elasticsearch.customHeaders: {}

## Time in milliseconds for Elasticsearch to wait for responses from shards. Set to 0 to disable.
#elasticsearch.shardTimeout: 30000

## =================== System: Elasticsearch (Optional) ===================
## These files are used to verify the identity of Kibana to Elasticsearch and are required when
## xpack.security.http.ssl.client_authentication in Elasticsearch is set to required.
#elasticsearch.ssl.certificate: /path/to/your/client.crt
#elasticsearch.ssl.key: /path/to/your/client.key

## Enables you to specify a path to the PEM file for the certificate
## authority for your Elasticsearch instance.
#elasticsearch.ssl.certificateAuthorities: [ "/path/to/your/CA.pem" ]

## To disregard the validity of SSL certificates, change this setting's value to 'none'.
elasticsearch.ssl.verificationMode: none

## =================== System: Logging ===================
## Set the value of this setting to off to suppress all logging output, or to debug to log everything. Defaults to 'info'
#logging.root.level: debug

## Enables you to specify a file where Kibana stores log output.
logging:
  appenders:
    file:
      type: file
      fileName: /var/log/kibana/kibana.log
      layout:
        type: json
  root:
    appenders:
      - default
      - file
##  policy:
##    type: size-limit
##    size: 256mb
##  strategy:
##    type: numeric
##    max: 10
##  layout:
##    type: json

## Logs queries sent to Elasticsearch.
#logging.loggers:
##  - name: elasticsearch.query
##    level: debug

## Logs http responses.
#logging.loggers:
##  - name: http.server.response
##    level: debug

## Logs system usage information.
#logging.loggers:
##  - name: metrics.ops
##    level: debug

## Enables debug logging on the browser (dev console)
#logging.browser.root:
##  level: debug

## =================== System: Other ===================
## The path where Kibana stores persistent data not saved in Elasticsearch. Defaults to data
#path.data: data

## Specifies the path where Kibana creates the process ID file.
pid.file: /run/kibana/kibana.pid

## Set the interval in milliseconds to sample system and process performance
## metrics. Minimum is 100ms. Defaults to 5000ms.
#ops.interval: 5000

## Specifies locale to be used for all localizable strings, dates and number formats.
## Supported languages are the following: English (default) "en", Chinese "zh-CN", Japanese "ja-JP", French "fr-FR".
#i18n.locale: "en"

## =================== Frequently used (Optional)===================

## =================== Saved Objects: Migrations ===================
## Saved object migrations run at startup. If you run into migration-related issues, you might need to adjust these settings.

## The number of documents migrated at a time.
## If Kibana can't start up or upgrade due to an Elasticsearch `circuit_breaking_exception`,
## use a smaller batchSize value to reduce the memory pressure. Defaults to 1000 objects per batch.
#migrations.batchSize: 1000

## The maximum payload size for indexing batches of upgraded saved objects.
## To avoid migrations failing due to a 413 Request Entity Too Large response from Elasticsearch.
## This value should be lower than or equal to your Elasticsearch cluster’s `http.max_content_length`
## configuration option. Default: 100mb
#migrations.maxBatchSizeBytes: 100mb

## The number of times to retry temporary migration failures. Increase the setting
## if migrations fail frequently with a message such as `Unable to complete the [...] step after
## 15 attempts, terminating`. Defaults to 15
#migrations.retryAttempts: 15

## =================== Search Autocomplete ===================
## Time in milliseconds to wait for autocomplete suggestions from Elasticsearch.
## This value must be a whole number greater than zero. Defaults to 1000ms
#unifiedSearch.autocomplete.valueSuggestions.timeout: 1000

## Maximum number of documents loaded by each shard to generate autocomplete suggestions.
## This value must be a whole number greater than zero. Defaults to 100_000
#unifiedSearch.autocomplete.valueSuggestions.terminateAfter: 100000
```

```bash
root@voidtrace:~# cat /etc/elasticsearch/elasticsearch.yml
## ======================== Elasticsearch Configuration =========================
##
## NOTE: Elasticsearch comes with reasonable defaults for most settings.
##       Before you set out to tweak and tune the configuration, make sure you
##       understand what are you trying to accomplish and the consequences.
##
## The primary way of configuring a node is via this file. This template lists
## the most important settings you may want to configure for a production cluster.
##
## Please consult the documentation for further information on configuration options:
## https://www.elastic.co/guide/en/elasticsearch/reference/index.html
##
## ---------------------------------- Cluster -----------------------------------
##
## Use a descriptive name for your cluster:
##
cluster.name: voidtrace
##
## ------------------------------------ Node ------------------------------------
##
## Use a descriptive name for the node:
##
node.name: voidtrace-node
##
## Add custom attributes to the node:
##
#node.attr.rack: r1
##
## ----------------------------------- Paths ------------------------------------
##
## Path to directory where to store the data (separate multiple locations by comma):
##
path.data: /var/lib/elasticsearch
##
## Path to log files:
##
path.logs: /var/log/elasticsearch
##
## ----------------------------------- Memory -----------------------------------
##
## Lock the memory on startup:
##
#bootstrap.memory_lock: true
##
## Make sure that the heap size is set to about half the memory available
## on the system and that the owner of the process is allowed to use this
## limit.
##
## Elasticsearch performs poorly when the system is swapping the memory.
##
## ---------------------------------- Network -----------------------------------
##
## By default Elasticsearch is only accessible on localhost. Set a different
## address here to expose this node on the network:
##
network.host: 0.0.0.0
##
## By default Elasticsearch listens for HTTP traffic on the first free port it
## finds starting at 9200. Set a specific HTTP port here:
##
#http.port: 9200
##
## For more information, consult the network module documentation.
##
## --------------------------------- Discovery ----------------------------------
##
## Pass an initial list of hosts to perform discovery when this node is started:
## The default list of hosts is ["127.0.0.1", "[::1]"]
##
#discovery.seed_hosts: ["host1", "host2"]
##
## Bootstrap the cluster using an initial set of master-eligible nodes:
##
#cluster.initial_master_nodes: ["node-1", "node-2"]
##
## For more information, consult the discovery and cluster formation module documentation.
##
## ---------------------------------- Various -----------------------------------
##
## Allow wildcard deletion of indices:
##
#action.destructive_requires_name: false

##----------------------- BEGIN SECURITY AUTO CONFIGURATION -----------------------
##
## The following settings, TLS certificates, and keys have been automatically
## generated to configure Elasticsearch security features on 25-04-2025 05:18:24
##
## --------------------------------------------------------------------------------

## Enable security features
xpack.security.enabled: true

xpack.security.enrollment.enabled: true

## Enable encryption for HTTP API client connections, such as Kibana, Logstash, and Agents
xpack.security.http.ssl:
  enabled: true
  keystore.path: certs/http.p12

## Enable encryption and mutual authentication between cluster nodes
xpack.security.transport.ssl:
  enabled: true
  verification_mode: certificate
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12
## Create a new cluster with the current node only
## Additional nodes can still join the cluster later
#cluster.initial_master_nodes: ["voidtrace"]
discovery.type: single-node
## Allow HTTP API connections from anywhere
## Connections are encrypted and require user authentication
http.host: 0.0.0.0

## Allow other nodes to join the cluster from anywhere
## Connections are encrypted and mutually authenticated
#transport.host: 0.0.0.0

##----------------------- END SECURITY AUTO CONFIGURATION -------------------------
```

