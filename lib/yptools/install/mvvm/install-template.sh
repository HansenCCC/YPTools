
starttime=$(date +%Y-%m-%d\ %H:%M:%S)
echo "🚀 开始时间 $starttime 🚀"
echo `pwd`

#export kSourceDir="~/Library/Developer/Xcode/Templates/Source/"
#export kTemplateUbanDir="~/Library/Developer/Xcode/Templates/Source/JiangXi\ Uban\ MVVM.xctemplate"

mkdir -p ~/Library/Developer/Xcode/Templates/Source/

rm -rf dir ~/Library/Developer/Xcode/Templates/Source/kMVVM.xctemplate

cp -R kMVVM.xctemplate  ~/Library/Developer/Xcode/Templates/Source/kMVVM.xctemplate

echo "🚀 结束时间 $endtime 🚀"
