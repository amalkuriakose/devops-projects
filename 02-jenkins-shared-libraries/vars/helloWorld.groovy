def call(String name) {
    sh "Hello ${name}"
    sh "This is a shared library script called from the main pipeline"
}