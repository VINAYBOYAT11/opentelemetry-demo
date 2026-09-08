# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM public.ecr.aws/opensearchproject/opensearch:3.7.0
USER 0
RUN /usr/share/opensearch/bin/opensearch-plugin remove opensearch-security-analytics && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-alerting && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-anomaly-detection && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-asynchronous-search && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-cross-cluster-replication && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-custom-codecs && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-flow-framework && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-geospatial && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-neural-search && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-knn && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-ltr && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-skills && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-ml && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-notifications && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-notifications-core && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-observability && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-performance-analyzer && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-reports-scheduler && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-search-relevance && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-system-templates && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-ubi && \
    /usr/share/opensearch/bin/opensearch-plugin remove query-insights

USER 1000
