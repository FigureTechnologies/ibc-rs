@Library('jenkins-pipeline') _
import com.figure.Common

def common = new Common(this)
def images = [
        'provenance-relayer': [
                'ns '    : ' apis ',
                'image'  : 'provenance-relayer',
                'applyFn': provenanceApplyDeploy,
                'patchFn': provenancePatchDeploy,
                'descr'  : 'pd'
        ]
]

def mkDockerProps(base) {
    def fixedBranchName = env.BRANCH_NAME.replaceAll("/", "-")
    def epBaseUrl = "${env.GCR_HOST}/${env.GCR_PROJECT}"
    def pioBaseUrl = "${env.GCR_HOST}/provenance-io"
    def epBranchTag = "$fixedBranchName-${env.BUILD_NUMBER}"

    return [
            'imageTag': "$epBaseUrl/$base:$epBranchTag",
            'imageTagBranch': "$epBaseUrl/$base:$fixedBranchName",
            'imageTagLatest': "$epBaseUrl/$base:latest",

            'pioImageTag': "$pioBaseUrl/$base:$epBranchTag",
            'pioImageTagBranch': "$pioBaseUrl/$base:$fixedBranchName",
            'pioImageTagLatest': "$pioBaseUrl/$base:latest",
    ]
}

pipeline {
    agent any

    environment {
        VERSION_TAG = "${env.BRANCH_NAME.replaceAll("/", "-")}-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                gitCheckout()
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    def dockerProps = mkDockerProps("provenance-faucet")
                    dockerBuild(".", dockerProps.imageTag, "Dockerfile")
                    dockerTag(dockerProps.imageTag, dockerProps.imageTagBranch)

                    if (env.BRANCH_NAME == env.CI_BRANCH) {
                        dockerTag(dockerProps.imageTag, dockerProps.imageTagLatest)
                    }

                    // Tag the images over to provenance.io repo
                    if (env.BRANCH_NAME == 'master') {
                        dockerTag(dockerProps.imageTag, dockerProps.pioImageTag)
                        dockerTag(dockerProps.imageTag, dockerProps.pioImageTagBranch)
                        dockerTag(dockerProps.imageTag, dockerProps.pioImageTagLatest)
                    }
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    def dockerProps = mkDockerProps("provenance-relayer")

                    dockerPush(dockerProps.imageTag, dockerProps.imageTagBranch)
                    if (env.BRANCH_NAME == env.CI_BRANCH) {
                        dockerPush(dockerProps.imageTagLatest)
                    }

                    // Copy the images over to provenance.io repo
                    if (env.BRANCH_NAME == 'master') {
                        dockerPush(dockerProps.pioImageTag, dockerProps.pioImageTagBranch, dockerProps.pioImageTagLatest)
                    }
                }
            }
        }
        stage('Git Tag') {
            steps {
                script {
                    if (env.BRANCH_NAME == "master") {
                        gitTag(this, env.BUILD_NUMBER, env.GIT_COMMIT, env.GIT_URL)
                    }
                }
            }
        }
    }

    post {
        always {
            postNotifySlack currentBuild.result
        }
    }
}

