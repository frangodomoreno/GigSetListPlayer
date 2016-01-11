# GigSetListPlayer
Application Android et iOS pour les musiciens, permettant de créer des setlist de concerts.

Pourquoi un telle application ?

Vous êtes un musicienne, musicien, chanteuse, chanteur et lors de vos prestations vous utilisez un gros classeur pour vous aider à vous souvenenir des paroles, accords ... ??

Alors cette application est faite pour vous !

Elle remplacera votre encombrant et assez disgracieux classeur sur scène !

Elle vous permettra simplement d’avoir sous vos yeux votre liste de chansons, les paroles,les grilles d’accords et les partitions.

Si vous utilisez des piste instrumentales, vous pourrez également les embarquer dans l’application, vous en controlerez le lancement .

# Environnement de développement

Cette application des développée sous Qt 5.5.1 .

Le module pdfCore sous iOS est basé sur le projet vfr de Julius Oklamcak : https://github.com/vfr/Viewer.

Le module pdf Android est basé sur MuPdf : http://mupdf.com/

# Synchro DropBox

Pour permettre la synchro, il faut référencer l'application chez DopBox : https://www.dropbox.com/developers.

Ajouter une application de type "App Folder".

Le fichier keys.h contient l'AppKey et le code secret attribué par DropBox à l'application.

L'Api DropBox est basée sur le projet de Lycis : https://github.com/lycis/QtDropbox

# Installation

Clonez le repo, ouvrez le fichier GigSetlistPlayer.pro dans Qt Creator, choississez les platformes cibles, compilez.
