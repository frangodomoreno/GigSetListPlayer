/***********************************************************************************
# Gig Setlist Player
#
# Application Android et iOS pour les musiciens, permettant de crÈer des setlist de concerts.
#
# Copyright (C) 2015  J-Y Priou MonasysInfo
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
***********************************************************************************/

package com.monasys.corePdf;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

public class viewPdf extends org.qtproject.qt5.android.bindings.QtActivity
{
	// this method is called by C++ to register the MuPdf Viewer.
	private RegisterReceiverRunnable pdfView = null;
	
    public void registerBroadcastReceiver(String pdfFile) {
        // Qt is running on a different thread than Android.
        // In order to view the Pdf File we need to execute it in the Android UI thread
    	//Log.d("Register", "Register with " + pdfFile + ": IT'S OK !!!!!!!! ");
    	pdfView = new RegisterReceiverRunnable(this,pdfFile) ;
        runOnUiThread(pdfView);
    }
    public void stopPdfView() {
    	Log.d("stopPdfView", "STOP VIEW PDF ------------------");
        if(pdfView != null ){
        	if(pdfView.intent != null)
        		stopService(pdfView.intent);
        }
    }
}