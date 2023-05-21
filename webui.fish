# fish shell function to easily start and stop webui
function webui
    switch $argv[1]
        case "start"
            aws ec2 start-instances --instance-ids <instance-id> --output text
        case "stop"
            aws ec2 stop-instances --instance-ids <instance-id> --output text
        case "status"
            aws ec2 describe-instances --instance-ids <instance-id> --query 'Reservations[].Instances[].State.Name' --output text
        case "*"
            echo "Unknown command: $argv[1]. Usage: webui [start|stop|status]"
    end
end
