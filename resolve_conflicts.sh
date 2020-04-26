# Copy resolve_conflicts.sh file to the root of your project ( where .xcodeproj package is )
# Open terminal, navigate to the project's folder and run the script using command: sh resolve_conflicts.sh
# All credits goes to Sergey Chehuta

projectfile=`find -d . -name 'project.pbxproj'`
projectdir=`echo *.xcodeproj`
projectfile="${projectdir}/project.pbxproj"
tempfile="${projectdir}/project.pbxproj.out"
savefile="${projectdir}/project.pbxproj.mergesave"

cat $projectfile | grep -v "<<<<<<< HEAD" | grep -v "=======" | grep -v "^>>>>>>> " > $tempfile
mv $tempfile $projectfile