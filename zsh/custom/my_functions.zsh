function cdapp {
  if [ $# -ne 1 ];
    then echo "Specify only one param -- the folder. For example Instagram."
  else
    cd $FBOBJC/Apps/$1
  fi
}

function editbashrc {
    vim ~/.bashrc
}

function editbashrc_atom {
    atom ~/.bashrc
}

function osappfolder {
  if [ $# -ne 1 ];
    then echo "Specify only one param -- the App name, for example Instagram."
  else
    return $OSDERIVED_DATA/$(ls $OSDERIVED_DATA | grep $1)
  fi
}

function oscreateapk {
  if [ $# -ne 1 ];
    then echo "Specify only one param -- the App name, for example Instagram."
  else
    FOLDER=$OSDERIVED_DATA/$(ls $OSDERIVED_DATA | grep $1)
    cdapp $1
    xcrun -n --sdk osmeta-android-Release+Asserts PackageApplication $FOLDER/Build/Products/Debug-osmeta-android/$1.app -o $1.apk
  fi
}

function osbuildandinstallsdk {
  if [ $# -ne 1 ];
    then echo "Specify only one param -- the target. For example Release+Asserts/android-arm."
  else
    os && make $1 sdk osmeta_runtime && osactivatesdk
  fi
}

function delete_dlls_in_winupaentry {
    echo "Deleting dlls from WinUAPEntry"
    LOCALHOST_HOME_DIR="/Users/mnovakovic/"
    DEVSERVER_HOME_DIR=$HOME
    WINUAP_ENTRY_DIR_RELATIVE_TO_HOME="repos/osmeta/osmeta/platform/windows/WinUAPEntry/WinUAPEntry"
    for file in $(ls $HOME/$WINUAP_ENTRY_DIR_RELATIVE_TO_HOME/*.dll | sort | grep -v App.dll)
    do
        echo "Deleting $file"
        rm $file
    done
    echo "Done!"
}

function rsync_devserver_winuapdlls {
    echo "Copying DLLs from devserver locally"
    # localhost = personal machine
    LOCALHOST_HOME_DIR="/Users/mnovakovic/"
    DEVSERVER_HOME_DIR=$HOME
    WINUAP_ENTRY_DIR_RELATIVE_TO_HOME="repos/osmeta/osmeta/platform/windows/WinUAPEntry/WinUAPEntry"
    for file in $(ls $DEVSERVER_HOME_DIR/$WINUAP_ENTRY_DIR_RELATIVE_TO_HOME/*.dll | sort | grep -v App.dll); do
        FILE_BASENAME=$(basename $file)
        rsync_devserver_file \
            $DEVSERVER_HOME_DIR/$WINUAP_ENTRY_DIR_RELATIVE_TO_HOME/$FILE_BASENAME \
            $LOCALHOST_HOME_DIR/$WINUAP_ENTRY_DIR_RELATIVE_TO_HOME/$FILE_BASENAME
    done
    echo "Done!"
}

function rsync_devserver_file {
    if [ $# -ne 2 ];
        then echo "Specify two params: local file and destination file;"
    else
        if [ -f $1 ];
            then rsync --checksum --progress -e ssh $1 localhost:$2
        else
            echo "The file $1 is not a regular file"
        fi
    fi
}

function rsync_sync_devserver_current_build {
    rsync_devserver_dir \
            "$HOME/repos/osmeta/build/$(readlink ~/repos/osmeta/build/current)/" \
            "$LOCAL_HOME/osmeta_rsync/$(readlink ~/repos/osmeta/build/current)"
}

function ostest_devserver_synced {
    if [ $# -ne 2 ];
      then echo "Specify two params: architecture and class name, for example  ostest Debug/Darwin-x86 test_NSProgress."
    else
        ~/repos/osmeta/osmeta/tools/sync_to_winphone_shell.py \
            ~/osmeta_rsync/$1 $2 && \
            ~/repos/osmeta/osmeta/tools/winphone_shell.py run --env WS_DRIVER=Null \
            $2
    fi
}

function rsync_devserver_dir {
    if [ $# -ne 2 ];
        then echo "Specify two params: local file and destination file;"
    else
        if [ -d $1 ];
        # v is verbose
        # a means recursive + preserver attributes
        # z means compress
            then rsync -avz --progress -e ssh $1 localhost:$2
        else
            echo "The file $1 is not a regular directory"
        fi
    fi
}

function ostestapppath {
  if [ $# -ne 2 ];
    then echo "Specify two params: architecture and class name, for example  ostest Debug/Darwin-x86 test_NSProgress."
  else
    echo $(find $OSMETA/build/$1 -name $2 | grep -v dSYM | grep -v osmeta-internal.platform)
  fi
}

function ostest {
  pushd $OSMETA
  if [ $# -ne 2 ];
    then echo "Specify two params: architecture and class name, for example  ostest Debug/Darwin-x86 test_NSProgress."
  else
    TEST_APP=$OSMETA/$(find build/$1 -name $2 | grep -v dSYM | grep -v osmeta-internal.platform)
    if [[ $(echo "$1" | grep "WinPhone") ]]; then
        make $1 $2 && osr && ~/repos/osmeta/osmeta/tools/sync_to_winphone_shell.py ~/repos/osmeta/build/WinPhone-current/ $2 && ~/repos/osmeta/osmeta/tools/winphone_shell.py run --env WS_DRIVER=Null $2
    fi

    if [[ $(echo "$1" | grep "WinStore") ]]; then
        make $1 $2 && osr && ~/repos/osmeta/osmeta/tools/sync_to_winphone_shell.py ~/repos/osmeta/build/WinStore-current/  && ~/repos/osmeta/osmeta/tools/winphone_shell.py run --env WS_DRIVER=Null $2
    fi

    if [[ $(echo "$1" | grep "Darwin") ]]; then
        make $1 $2 && cd build && cd $1 && $TEST_APP
    fi

    if [[ $(echo "$1" | grep "Linux") ]]; then
        make $1 $2 && cd build && cd $1 && $TEST_APP
    fi
  fi
  popd
}


function osdebug {
    if [ $# -ne 2 ];
        then echo "Specify two params: architecture and class name, for example  ostest Debug/Darwin-x86 test_NSProgress."
    else
        if [[ $(echo "$1" | grep "Darwin") ]]; then
                os && make $1 $2
            test_filename=$(find . -name $2 | grep -v dSYM | grep -v osmeta-internal.platform)
            ~/repos/osmeta/prebuilt/devbin/lldb $test_filename
        fi
    fi
}

function upload {
  osr && repo rebase && repo upload .
}

function reload {
  source ~/.bashrc;
}

function osgettranslations() {
    osr
    ./tools/i18n/update.py bn_IN,cs_CZ,da_DK,de_DE,el_GR,en_GB,es_ES,es_LA,fi_FI,fr_FR,gu_IN,hi_IN,hr_HR,hu_HU,id_ID,it_IT,ja_JP,kn_IN,ko_KR,ml_IN,mr_IN,ms_MY,nb_NO,ne_NP,nl_NL,pa_IN,pl_PL,pt_BR,pt_PT,ro_RO,ru_RU,si_LK,sk_SK,sv_SE,ta_IN,te_IN,th_TH,tr_TR,ur_PK,vi_VN,zh_CN,zh_HK,zh_TW
}

function osgettranslationssmall() {
    osr
    ./tools/i18n/update.py en_GB,es_ES,fr_FR,it_IT,ja_JP,ko_KR,ur_PK,zh_CN,zh_HK,zh_TW
}

function osprepackageapp {
    if [ $# -ne 2 ];
        then
            echo "The param needs to be architecture name, for example Debug/Darwin-x86"
            echo "followed by the full path to the .app"
    else
        PLATFORM_NAME=$(echo $1 | awk -F/ '{print $2}')
        BUILD_TYPE=$(echo $1 | awk -F/ '{print $1}')

        OSMETA_REPO_DIR="$HOME/repos/osmeta"
        IOS_PROJECT_PATH="$HOME/repos/FTCalendar/"
        IOS_OSMETA_BUILD_DIR="$IOS_PROJECT_PATH/build"

        XCRUN=~/.xcsdk/bin/xcrun

        OSMETA_BUILD_TYPE="None"
        OSMETA_PLATFORM_TYPE=""
        OSMETA_ARCHITECTURE=""

        case "$BUILD_TYPE" in
            "Debug")
            OSMETA_BUILD_TYPE="-Debug"
            ;;

            "CompactDebug")
            OSMETA_BUILD_TYPE="-CompactDebug"
            ;;

            "Release")
            OSMETA_BUILD_TYPE=""
            ;;

            "NonCompactRelease")
            OSMETA_BUILD_TYPE="-NonCompactRelease"
            ;;
        esac

        if [[ "$OSMETA_BUILD_TYPE" == "None" ]]; then
            echo "Build type is wrong!"
            return 1
        fi

        case "$PLATFORM_NAME" in
            "Darwin-x86")
            OSMETA_PLATFORM_TYPE="osx"
            OSMETA_ARCHITECTURE="i386"
            ;;

            "WinPhone-arm")
            OSMETA_PLATFORM_TYPE="winphone"
            OSMETA_ARCHITECTURE="armv7"
            ;;

            "WinStore-x86")
            OSMETA_PLATFORM_TYPE="winstore"
            OSMETA_ARCHITECTURE="i386"
            ;;

            "WinStore-x86_64")
            OSMETA_PLATFORM_TYPE="winstore"
            OSMETA_ARCHITECTURE="x86_64"
            ;;
        esac

        if [[ "$OSMETA_PLATFORM_TYPE" == "" ]]; then
            echo "Platform is wrong!"
            return 1
        fi

        OSMETA_SDK="osmeta-$OSMETA_PLATFORM_TYPE$OSMETA_BUILD_TYPE"
        OSMETA_XCODEBUILD_CONFIGURATION="$BUILD_TYPE"
        OUTPUT_DIRECTORY="$HOME/tmp/EXTRACTED_$(date "+%B_%d_at_%H_%M")"


        APP_PATH=$2
        APP_OUTPUT_PATH=$HOME/app_repackaged
        ZIPPED_APPX_PATH=$APP_OUTPUT_PATH/ZIPPED_APPX.zip

        rm -rf $APP_OUTPUT_PATH
        mkdir $APP_OUTPUT_PATH

        if [[ "$APP_PATH" == "" ]]; then
            echo "Platform is wrong!"
            return 1
        fi

        echo "Building the runtime"
        os && make $1 sdk runtime

        #cp $IOS_PROJECT_PATH/AppIcon40x40.png $APP_PATH && \

        $XCRUN -n --sdk $OSMETA_SDK PackageApplication --no-appx $APP_PATH -o $APP_OUTPUT_PATH && \
        $XCRUN -n --sdk $OSMETA_SDK PackageApplication $APP_PATH -c "$($XCRUN -n -sdk $OSMETA_SDK --show-sdk-path)/$OSMETA_ARCHITECTURE/Support/resources/WinUAPEntry_TemporaryKey.pfx" --dev-installer -o $ZIPPED_APPX_PATH

        echo "*******************"
        echo "Your zip is at $ZIPPED_APPX_PATH"
        echo "*******************"
    fi
}

function osftproject {
    if [ $# -ne 1 ];
        then echo "The param needs to be architecture name, for example Debug/Darwin-x86."
    else
        PLATFORM_NAME=$(echo $1 | awk -F/ '{print $2}')
        BUILD_TYPE=$(echo $1 | awk -F/ '{print $1}')

        PROJECT_NAME="PICatalog"
        OSMETA_REPO_DIR="$HOME/repos/osmeta"
        IOS_PROJECT_PATH="$OSMETA/demo/osmeta/PlatformIntegration/PICatalog/"
        USER_LIBRARY_DIR="$HOME/Library"
        DERIVED_DATA_DIR="$USER_LIBRARY_DIR/Developer/Xcode/DerivedData"

        XCRUN=~/.xcsdk/bin/xcrun
        if hash xcodebuild 2>/dev/null; then
            XCODEBUILD=xcodebuild
            IOS_OSMETA_BUILD_DIR="$IOS_PROJECT_PATH/build"
        else
            XCODEBUILD=~/.xcsdk/bin/xcbuild
            IOS_OSMETA_BUILD_DIR="$DERIVED_DATA_DIR/$PROJECT_NAME-*"
        fi

        OSMETA_BUILD_TYPE="None"
        OSMETA_PLATFORM_TYPE=""
        OSMETA_ARCHITECTURE=""

        case "$BUILD_TYPE" in
            "Debug")
            OSMETA_BUILD_TYPE="-Debug"
            ;;

            "CompactDebug")
            OSMETA_BUILD_TYPE="-CompactDebug"
            ;;

            "Release")
            OSMETA_BUILD_TYPE=""
            ;;

            "NonCompactRelease")
            OSMETA_BUILD_TYPE="-NonCompactRelease"
            ;;
        esac

        if [[ "$OSMETA_BUILD_TYPE" == "None" ]]; then
            echo "Build type is wrong!"
            return 1
        fi

        case "$PLATFORM_NAME" in
            "Darwin-x86")
            OSMETA_PLATFORM_TYPE="osx"
            OSMETA_ARCHITECTURE="i386"
            ;;

            "WinPhone-arm")
            OSMETA_PLATFORM_TYPE="winphone"
            OSMETA_ARCHITECTURE="armv7"
            ;;

            "WinStore-x86")
            OSMETA_PLATFORM_TYPE="winstore"
            OSMETA_ARCHITECTURE="i386"
            ;;
        esac

        if [[ "$OSMETA_PLATFORM_TYPE" == "" ]]; then
            echo "Platform is wrong!"
            return 1
        fi

        OSMETA_SDK="osmeta-$OSMETA_PLATFORM_TYPE$OSMETA_BUILD_TYPE"
        OSMETA_XCODEBUILD_CONFIGURATION="$BUILD_TYPE"
        OUTPUT_DIRECTORY="$HOME/tmp/EXTRACTED_$(date "+%B_%d_at_%H_%M")"

        cd "$OSMETA_REPO_DIR" && \
        make $1 sdk runtime && osactivatesdk && \
        cd $IOS_PROJECT_PATH && \
        rm -rf $IOS_OSMETA_BUILD_DIR && \
        $XCODEBUILD -sdk $OSMETA_SDK -arch $OSMETA_ARCHITECTURE -configuration $OSMETA_XCODEBUILD_CONFIGURATION -project PICatalog.xcodeproj TOOLCHAINS=com.facebook.osmeta.stable.noasserts && \
        rm -rf ./output/ && mkdir output && \
        $XCRUN -n --sdk $OSMETA_SDK PackageApplication --no-appx $(find $IOS_OSMETA_BUILD_DIR -name PICatalog.app) -o $IOS_PROJECT_PATH\output && \
        cd ~/repos/osmeta && \
        make $1 WinUAPEntry_runtime && \
        cd $IOS_PROJECT_PATH && \
        \cp -Rf $IOS_PROJECT_PATH/output/* ~/repos/osmeta/osmeta/platform/windows/WinUAPEntry/WinUAPEntry/
        #\cp -f $IOS_PROJECT_PATH/AppIcon40x40.png $(find $IOS_OSMETA_BUILD_DIR -name PICatalog.app) &&
        cd $IOS_PROJECT_PATH/output/ && \
        $XCRUN -n --sdk $OSMETA_SDK PackageApplication $(find $IOS_OSMETA_BUILD_DIR -name PICatalog.app) -c "$($XCRUN -n -sdk $OSMETA_SDK --show-sdk-path)/$OSMETA_ARCHITECTURE/Support/resources/WinUAPEntry_TemporaryKey.pfx" --dev-installer -o ~/tmp/PICatalog.zip && \
        mkdir "$OUTPUT_DIRECTORY" && \
        unzip -o ~/tmp/PICatalog.zip -d $OUTPUT_DIRECTORY && \
        $HOME/repos/osmeta/osmeta/tools/appx_unpack.py "$OUTPUT_DIRECTORY/App.appx" "$OUTPUT_DIRECTORY/appx_unpacked" && \
        # cat $OUTPUT_DIRECTORY/appx_unpacked/AppxManifest.xml && \
        osr
    fi
}
