ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF 2> /dev/null
    [[ ! -d /var/lib/jenkins/jobs/${job} ]] && echo "This task has been done" || {
        echo "Job exists."
    }
EOF