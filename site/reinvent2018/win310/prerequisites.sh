export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
aws ec2 create-key-pair --region eu-west-1 --key-name win310 
aws cloudformation deploy --region eu-west-1 --template-file prerequisites.yml --stack-name win310 --parameter-overrides MainPassword=reInvent2018! KeyPairName=win310 --capabilities CAPABILITY_NAMED_IAM
