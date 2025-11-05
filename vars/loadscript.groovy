def call(map config [:]){
    def scriptData = libraryResource "${config.name}"
    writeFile file: "${config.name}" , text: scriptData 
    sh"chmod +x ./${config.name}"

}