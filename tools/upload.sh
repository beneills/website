./build.sh
echo "Finished build!"
s3cmd put --recursive ../_site/* s3://www.beneills.com
echo "Finished upload!"
