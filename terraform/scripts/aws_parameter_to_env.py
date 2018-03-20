import sys, json, os

aws_data = json.load(os.popen("aws ssm get-parameters-by-path --with-decryption --path " + sys.argv[1] + " --region " + sys.argv[2]))['Parameters']

f = open(sys.argv[3],'w')

for item in aws_data:
  f.write(item['Name'].split('/')[-1].upper() + "=" + item['Value'] + "\n")

f.close()
