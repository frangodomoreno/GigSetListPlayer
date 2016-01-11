/***********************************************************************************
# Gig Setlist Player
#
# Application Android et iOS pour les musiciens, permettant de créer des setlist de concerts.
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

.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

var db = Sql.LocalStorage.openDatabaseSync("AutomationDB","1.0","Automation DataBase",5000000);

function init() {
  db.transaction(
    function(tx) {
        //tx.executeSql('drop TABLE LyricsFontSize;')
        var colScrollVarExists=false
        tx.executeSql('CREATE TABLE IF NOT EXISTS Automation(id INTEGER PRIMARY KEY, tuneTitle TEXT , position REAL, slower INT, scrollvariation REAL);')
        tx.executeSql('CREATE TABLE IF NOT EXISTS LyricsFontSize(id INTEGER PRIMARY KEY, tuneTitle TEXT , textFontSize REAL, currentList TEXT);')

        var rs=tx.executeSql('PRAGMA table_info(Automation);')
        for (var i = 0; i < rs.rows.length; i++) {
            if(rs.rows.item(i).name === "scrollvariation")
                colScrollVarExists=true
        }
        if(!colScrollVarExists){
            tx.executeSql('ALTER TABLE Automation ADD COLUMN scrollvariation REAL DEFAULT 0.1;')
        }
    }
  )
}

function getRecords(tuneTitle) {
  var records = new Array(0)
  db.transaction(
    function(tx) {
          var rs = tx.executeSql('SELECT * FROM Automation where tuneTitle=?;',[tuneTitle]);
          for (var i = 0; i < rs.rows.length; i++) {
                var record = new Object
                record.id = rs.rows.item(i).id
                record.tuneTitle = rs.rows.item(i).tuneTitle
                record.position = rs.rows.item(i).position
                record.slower = rs.rows.item(i).slower
                record.scrollvariation = rs.rows.item(i).scrollvariation
                records.push(record)
          }
    }
  );
  return records
}

function insertRecord(tuneTitle,position,slower,scrollvariation) {
  db.transaction(
    function(tx) {
      tx.executeSql('INSERT INTO Automation VALUES(NULL, ?,?,?,?);', [ tuneTitle,position,slower,scrollvariation ]);
    }
  );
}

function removeRecord(tuneTitle) {
  db.transaction(
    function(tx) {
      tx.executeSql('DELETE FROM Automation WHERE tuneTitle=?;', [ tuneTitle]);
    }
  );
}

function updateFontSize(tuneTitle,textFontSize,currentList) {
    db.transaction(
      function(tx) {
        var rs = tx.executeSql('SELECT * FROM LyricsFontSize where tuneTitle=? and currentList = ? ;',[tuneTitle,currentList]);
        if(rs.rows.length == 0){
            // Create new record
            tx.executeSql('INSERT INTO LyricsFontSize VALUES(NULL, ?,?,?);', [ tuneTitle,textFontSize,currentList]);
        }
        else{
            // Update existing
            tx.executeSql('UPDATE LyricsFontSize SET textFontSize = ? ;', [ textFontSize]);
        }
      }
    );
}

function loadFontSize(tuneTitle,currentList) {
    var textFontSize
    db.transaction(
      function(tx) {
        var rs = tx.executeSql('SELECT * FROM LyricsFontSize where tuneTitle=? and currentList = ? ;',[tuneTitle,currentList]);
        if(rs.rows.length == 0){
            // No record return 0
            textFontSize=0.0
        }
        else{
            // Return fontSize readed
            textFontSize= rs.rows.item(0).textFontSize
        }
      }
    );
    return textFontSize
}
