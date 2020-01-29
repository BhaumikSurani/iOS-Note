Install simple Lib write following in pod file

pod ‘LibName’



Install Lib From fork by user write following in pod file

pod ‘LibName’, :git => 'https://github.com/YourLibURL’



Install Lib From Local storage

pod ‘LibName’, :path => ‘./YourLibLocation’



Error:- [!] CDN: trunk Repo update failed 
CocoaPods 1.8.x offers the ability to use either git or CDN. CDN is the default but for those who it doesn't work you can always fallback to the previous git based implementation by adding...

Add source in Podfile

Ex:-
source 'https://github.com/CocoaPods/Specs.git'
target 'Project' do
  #use_frameworks!
  pod 'AFNetworking'
end

then run command in terminal "pod install"
then run command in terminal "pod repo remove trunk"
