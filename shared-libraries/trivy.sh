def call(Map config = [:]) {
    loadscript(name: 'trivy.sh')
    sh """
        ./trivy.sh ${config.imageName} ${config.severity ?: 'HIGH,CRITICAL'} ${config.exitCode ?: 0} ${config.format ?: 'json'}
    """

    sh '''
        trivy convert \
          --format template \
          --template "@/usr/local/share/trivy/templates/html.tpl" \
          --output trivy-image-HIGH-results.html trivy-image-HIGH-results.json || true

        trivy convert \
          --format template \
          --template "@/usr/local/share/trivy/templates/html.tpl" \
          --output trivy-image-CRITICAL-results.html trivy-image-CRITICAL-results.json || true

        trivy convert \
          --format template \
          --template "@/usr/local/share/trivy/templates/junit.tpl" \
          --output trivy-image-HIGH-results.xml trivy-image-HIGH-results.json || true

        trivy convert \
          --format template \
          --template "@/usr/local/share/trivy/templates/junit.tpl" \
          --output trivy-image-CRITICAL-results.xml trivy-image-CRITICAL-results.json || true
    '''

    publishHTML([
        allowMissing: true,
        alwaysLinkToLastBuild: true,
        keepAll: true,
        reportDir: '.',
        reportFiles: 'trivy-image-HIGH-results.html',
        reportName: 'Trivy Scan Report (High)',
        reportTitles: 'High Severity Vulnerability Scan'
    ])

    publishHTML([
        allowMissing: true,
        alwaysLinkToLastBuild: true,
        keepAll: true,
        reportDir: '.',
        reportFiles: 'trivy-image-CRITICAL-results.html',
        reportName: 'Trivy Scan Report (Critical)',
        reportTitles: 'Critical Severity Vulnerability Scan'
    ])
}
