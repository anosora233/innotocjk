MODDIR=${0%/*}

insert() {
    name=$1
    font=$2
    file=$3

    sed -i '
    s#<family name="'$name'">#\
    <family name="'$name'">\
        <font weight="100" style="normal">'$font'<axis tag="wght" stylevalue="100" /></font>\
        <font weight="200" style="normal">'$font'<axis tag="wght" stylevalue="200" /></font>\
        <font weight="300" style="normal">'$font'<axis tag="wght" stylevalue="300" /></font>\
        <font weight="400" style="normal">'$font'<axis tag="wght" stylevalue="400" /></font>\
        <font weight="500" style="normal">'$font'<axis tag="wght" stylevalue="500" /></font>\
        <font weight="600" style="normal">'$font'<axis tag="wght" stylevalue="600" /></font>\
        <font weight="700" style="normal">'$font'<axis tag="wght" stylevalue="700" /></font>\
        <font weight="800" style="normal">'$font'<axis tag="wght" stylevalue="800" /></font>\
        <font weight="900" style="normal">'$font'<axis tag="wght" stylevalue="900" /></font>\
    </family>\
    <family>#g
    ' $file
}

insert_cjk() {
    lang=$1
    index=$2
    sans=$3
    serif=$4
    file=$5

    sed -i '
    s#<family lang="'$lang'">#\
    <family lang="'$lang'">\
        <font weight="100" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="100" /></font>\
        <font weight="200" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="200" /></font>\
        <font weight="300" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="300" /></font>\
        <font weight="400" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="400" /></font>\
        <font weight="500" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="500" /></font>\
        <font weight="600" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="600" /></font>\
        <font weight="700" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="700" /></font>\
        <font weight="800" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="800" /></font>\
        <font weight="900" style="normal" index="'$index'">'$sans'<axis tag="wght" stylevalue="900" /></font>\
        \
        <font weight="100" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="100" /></font>\
        <font weight="200" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="200" /></font>\
        <font weight="300" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="300" /></font>\
        <font weight="400" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="400" /></font>\
        <font weight="500" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="500" /></font>\
        <font weight="600" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="600" /></font>\
        <font weight="700" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="700" /></font>\
        <font weight="800" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="800" /></font>\
        <font weight="900" style="normal" index="'$index'" fallbackFor="serif">'$serif'<axis tag="wght" stylevalue="900" /></font>\
    </family>\
    <family>#g
    ' $file
}

patch() {
    file=$1
    # non-cjk
    insert "serif" "NotoSerif-VF.ttf" $file
    insert "sans-serif" "Inter-VF.ttf" $file
    insert "sys-sans-en" "Inter-VF.ttf" $file
    insert "monospace" "NotoSansMono-VF.ttf" $file
    # cjk
    insert_cjk "ja" "0" "NotoSansCJK-VF.ttc" "NotoSerifCJK-VF.ttc" $file
    insert_cjk "ko" "1" "NotoSansCJK-VF.ttc" "NotoSerifCJK-VF.ttc" $file
    insert_cjk "zh-Hans" "2" "NotoSansCJK-VF.ttc" "NotoSerifCJK-VF.ttc" $file
    insert_cjk "zh-Hant" "3" "NotoSansCJK-VF.ttc" "NotoSerifCJK-VF.ttc" $file
    insert_cjk "zh-Bopo" "3" "NotoSansCJK-VF.ttc" "NotoSerifCJK-VF.ttc" $file
    insert_cjk "zh-Hant,zh-Bopo" "3" "NotoSansCJK-VF.ttc" "NotoSerifCJK-VF.ttc" $file
}

# mount fonts
mount -t overlay overlay -o lowerdir=$MODDIR/fonts:/system/fonts /system/fonts

# generic fonts.xml
base=/system/etc/fonts.xml
if [ -e $base ]; then
    cp -af $base $MODDIR/1.xml
    patch $MODDIR/1.xml
    mount --bind $MODDIR/1.xml $base
fi

# oplus fonts_base.xml
oplus=/system_ext/etc/fonts_base.xml
if [ -e $oplus ]; then
    cp -af $oplus $MODDIR/2.xml
    patch $MODDIR/2.xml
    mount --bind $MODDIR/2.xml $oplus
fi

# oplus clock font
clock=/system/fonts/SysSans-En-Regular.ttf
if [ -e $clock ]; then
    mount --bind /system/fonts/Inter-VF.ttf $clock
fi
