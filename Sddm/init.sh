#!/bin/bash
sudo apt-get install libqscintilla2-qt5-15 \
libqscintilla2-qt5-l10n \
libqt5charts5 \
libqt5concurrent5 \
libqt5core5a \
libqt5dbus5 \
libqt5gui5 \
libqt5multimedia5 \
libqt5network5 \
libqt5opengl5 \
libqt5printsupport5 \
libqt5qml5 \
libqt5qmlmodels5 \
libqt5qmlworkerscript5 \
libqt5quick5 \
libqt5quickcontrols2-5 \
libqt5quicktemplates2-5 \
libqt5quickwidgets5 \
libqt5sql5-sqlite \
libqt5sql5 \
libqt5svg5 \
libqt5waylandclient5 \
libqt5waylandcompositor5 \
libqt5websockets5 \
libqt5widgets5 \
libqt5x11extras5 \
libqt5xml5 \
qml-module-qt-labs-folderlistmodel \
qml-module-qt-labs-settings \
qml-module-qtgraphicaleffects \
qml-module-qtqml-models2 \
qml-module-qtqml \
qml-module-qtquick-controls2 \
qml-module-qtquick-controls \
qml-module-qtquick-dialogs \
qml-module-qtquick-extras \
qml-module-qtquick-layouts \
qml-module-qtquick-privatewidgets \
qml-module-qtquick-templates2 \
qml-module-qtquick-window2 \
qml-module-qtquick2 \
qt5-gtk-platformtheme \
qt5-image-formats-plugins \
qt5-style-kvantum-l10n \
qt5-style-kvantum-themes \
qt5-style-kvantum \
qt5ct \
qttranslations5-l10n \
qtwayland5
sudo apt-get install sddm
sudo systemctl disable gdm3
sudo systemctl enable sddm
sudo mkdir /etc/sddm.conf.d -p
sudo cp sddm.conf /etc/sddm.conf.d/sddm.conf
sudo cp -r ../Sddm /usr/share/sddm/themes
