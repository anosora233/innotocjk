MODDIR=${0%/*}

rep() {
    name=$1
    font=$2
    file=$3

    sed -i '
    /<family name="'$name'">/,/<\/family>/c\
    <family name="'$name'">\
        <font weight="100" style="normal">'$font'<axis tag="wght" stylevalue="100"\/><\/font>\
        <font weight="200" style="normal">'$font'<axis tag="wght" stylevalue="200"\/><\/font>\
        <font weight="300" style="normal">'$font'<axis tag="wght" stylevalue="300"\/><\/font>\
        <font weight="400" style="normal">'$font'<axis tag="wght" stylevalue="400"\/><\/font>\
        <font weight="500" style="normal">'$font'<axis tag="wght" stylevalue="500"\/><\/font>\
        <font weight="600" style="normal">'$font'<axis tag="wght" stylevalue="600"\/><\/font>\
        <font weight="700" style="normal">'$font'<axis tag="wght" stylevalue="700"\/><\/font>\
        <font weight="800" style="normal">'$font'<axis tag="wght" stylevalue="800"\/><\/font>\
        <font weight="900" style="normal">'$font'<axis tag="wght" stylevalue="900"\/><\/font>\
    <\/family>' $file
}

cjk() {
    lang=$1
    index=$2
    file=$3

    sans="NotoSansCJK-VF.ttc"
    serif="NotoSerifCJK-VF.ttc"

    sed -i '
    /<family lang="'$lang'">/,/<\/family>/c\
    <family lang="'$lang'">\
        <font weight="100" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="100"\/><\/font>\
        <font weight="200" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="200"\/><\/font>\
        <font weight="300" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="300"\/><\/font>\
        <font weight="400" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="400"\/><\/font>\
        <font weight="500" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="500"\/><\/font>\
        <font weight="600" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="600"\/><\/font>\
        <font weight="700" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="700"\/><\/font>\
        <font weight="800" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="800"\/><\/font>\
        <font weight="900" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="900"\/><\/font>\
        \
        <font weight="100" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="100"\/><\/font>\
        <font weight="200" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="200"\/><\/font>\
        <font weight="300" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="300"\/><\/font>\
        <font weight="400" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="400"\/><\/font>\
        <font weight="500" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="500"\/><\/font>\
        <font weight="600" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="600"\/><\/font>\
        <font weight="700" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="700"\/><\/font>\
        <font weight="800" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="800"\/><\/font>\
        <font weight="900" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="900"\/><\/font>\
    <\/family>' $file
}

patch() {
    file=$1
    # append | sans-serif
    sed -i '
    /<family name="sans-serif">/a\
        <font weight="100" style="normal">Inter-VF.ttf<axis tag="wght" stylevalue="100"\/><\/font>\
        <font weight="200" style="normal">Inter-VF.ttf<axis tag="wght" stylevalue="200"\/><\/font>\
        <font weight="300" style="normal">Inter-VF.ttf<axis tag="wght" stylevalue="300"\/><\/font>\
        <font weight="400" style="normal">Inter-VF.ttf<axis tag="wght" stylevalue="400"\/><\/font>\
        <font weight="500" style="normal">Inter-VF.ttf<axis tag="wght" stylevalue="500"\/><\/font>\
        <font weight="600" style="normal">Inter-VF.ttf<axis tag="wght" stylevalue="600"\/><\/font>\
        <font weight="700" style="normal">Inter-VF.ttf<axis tag="wght" stylevalue="700"\/><\/font>\
        <font weight="800" style="normal">Inter-VF.ttf<axis tag="wght" stylevalue="800"\/><\/font>\
        <font weight="900" style="normal">Inter-VF.ttf<axis tag="wght" stylevalue="900"\/><\/font>\
    <\/family>\
    <family>' $file
    # alias | sys-sans-en
    sed -i '
    /<family name="sys-sans-en">/,/<\/family>/c\
    <alias name="sys-sans-en" to="sans-serif" \/>' $file
    # change | serif & monospac
    rep "serif" "NotoSerif-VF.ttf" $file
    rep "monospace" "NotoSansMono-VF.ttf" $file
    # change | cjk
    cjk "ja" 0 $file
    cjk "ko" 1 $file
    cjk "zh-Hans" 2 $file
    cjk "zh-Hant zh-Bopo" 3 $file
    cjk "zh-Hant,zh-Bopo" 3 $file
}

# mount fonts
mount -t overlay overlay -o lowerdir=$MODDIR/fonts:/system/fonts /system/fonts

# main fonts.xml
temp=$MODDIR/main.xml
main=/system/etc/fonts.xml
if [ -e $main ]; then
    cp -af $main $temp
    patch $temp
    mount --bind $temp $main
fi

# base fonts.xml
temp=$MODDIR/base.xml
base=/system/system_ext/etc/fonts_base.xml
if [ -e $base ]; then
    cp -af $base $temp
    patch $temp
    mount --bind $temp $base
fi

# oplus clock
temp=$MODDIR/fonts/Inter-VF.ttf
sans=/system/fonts/SysSans-En-Regular.ttf
if [ -e $sans ]; then
    mount --bind $temp $sans
fi
