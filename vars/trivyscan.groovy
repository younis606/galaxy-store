def vulnerability(map config = [:]) {
    loadscript(name: trivy.sh)
    sh "./trivy.sh ${config.imageName} ${config.severity} ${config.exitCode}"
}