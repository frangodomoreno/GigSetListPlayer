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

import com.artifex.mupdfdemo.MuPDFActivity;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.util.Log;
 
public class RegisterReceiverRunnable implements Runnable
{
    private Activity m_activity;
    private String pdf ;
    public Intent intent = null;
    
    public RegisterReceiverRunnable(Activity activity,String pdfFile) {
        m_activity = activity;
        pdf = pdfFile ;
    }
    // this method is called on Android Ui Thread
    @Override
    public void run() {
    	//Log.d("Runnable", "Runnable with " + pdf + ": IT'S OK !!!!!!!! ");
  		Uri uri = Uri.parse(pdf);
  		intent = new Intent(m_activity, MuPDFActivity.class);
        intent.setAction(Intent.ACTION_VIEW);
  		intent.setData(uri);
		m_activity.startActivity(intent);
    }
}