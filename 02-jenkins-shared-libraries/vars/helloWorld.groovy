def call(String name) {
    sh "Hello ${name}. This is a shared library script called from the main pipeline"
}