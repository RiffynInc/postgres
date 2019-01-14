properties([
  parameters([
    string(defaultValue: 'riffyn-REL_11_STABLE', description: '', name: 'POSTGRES_CUSTOM_BRANCH', trim: true),
   ])
])

podTemplate(
  label: "postgres-build-pod",
  containers: [
    containerTemplate(name: 'jenkins-slave',
                      image: 'jenkins/jnlp-slave:3.10-1',
                      ttyEnabled: true,
                      command: 'cat',
                      resourceLimitCpu:      '100m',
                      resourceRequestMemory: '100Mi',
                      resourceLimitMemory:   '100Mi'),
    containerTemplate(name: 'gcc',
                      image: 'gcc:7.3',
                      command: 'cat',
                      ttyEnabled: true,
                      resourceLimitCpu:      '100m',
                      resourceRequestMemory: '100Mi',
                      resourceLimitMemory:   '100Mi'),
    containerTemplate(name: 'docker',
                      image: 'docker:1.12.6',
                      command: 'cat',
                      ttyEnabled: true,
                      resourceLimitCpu:      '100m',
                      resourceRequestMemory: '100Mi',
                      resourceLimitMemory:   '100Mi')
  ],
  volumes:[
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
  ]
)
{
  node("postgres-build-pod") {
    container('jenkins-slave') {
      stage('Clone repository') {
        checkout([
          $class: 'GitSCM',
          branches: [[name: "*/${env.BRANCH_NAME}"]],
          userRemoteConfigs: scm.userRemoteConfigs
        ])
      }
    }

    container('gcc') {
      stage('run configure') {
        sh './configure'
      }
      stage('run build') {
        sh 'make'
      }
    }

    container('docker') {
      def app
      stage('Build container') {
        app = docker.build("riffyninc/postgres:${env.BRANCH_NAME}-${env.BUILD_NUMBER}")
      }
      stage('Push container') {
        docker.withRegistry('https://registry.hub.docker.com', 'riffynbuild-dockerhub-credentials') {
          app.push()
          app.push("${env.BRANCH_NAME}-latest")
        }
      }
    }
  }
}