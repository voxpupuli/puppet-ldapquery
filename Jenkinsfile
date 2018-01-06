pipeline {
  agent any

  environment {
    PATH = "$PATH:~/.rbenv/bin"
  }

  stages {
    stage('printenv') {
      steps {
        sh 'printenv'
      }
    }
    stage('bundle') {
      steps {
        sh 'bundle'
      }
    }
    stage('rake test') {
      steps {
        sh 'bundle exec rake test'
      }
    }
    stage('module:build') {
      steps {
        sh 'bundle exec rake module:build'
      }
    }
  }
}
