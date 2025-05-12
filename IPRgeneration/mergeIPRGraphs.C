/*  script to merge IPR graphs
 *  produced for each telescopes into
 *  a singel file as required for the
 *  eventdisplay analysis
 *
 *  root -l -q -b 'mergeIPRGraphs.C( "output.root", "inputdirectory/" )'
 *.
 *. If the output file name contains the word "halfmoon", e.g., prod5-halfmoon-ze-20-IPR.root,
 *. then the halfmoon pedestal files are merged.
 */

vector< string > get_file_list( string iFileListName )
{
    vector< string > file_list;

    ifstream is( iFileListName.c_str(), ifstream::in );
    if( !is ) return file_list;
    string is_line;
    while( getline( is, is_line ) )
    {
        file_list.push_back( is_line );
    }
    return file_list;
}

void mergeIPRGraphs( string iMergedFile = "prod6-ze-20-IPR.root",
                     string iFileListName = "filelist.txt" )
{
     TFile *f = new TFile( iMergedFile.c_str(), "RECREATE" );
     if( f->IsZombie() )
     {
         cout << "Error creating new IPR graph file " << iMergedFile << endl;
         return;
     }
     cout << "Merged IPRs graphs will be written to " << iMergedFile << endl;

     cout << "Reading list of files: " << iFileListName << endl;
     vector< string > file_list = get_file_list( iFileListName );
     cout << "Number of files to be merged: " << file_list.size() << endl;
     if( file_list.size() == 0 ) return;

     for( unsigned int i = 0; i < file_list.size(); i++ )
     {
          TFile *iF = new TFile( file_list[i].c_str() );
          if( iF->IsZombie() )
          {
              continue;
          }
          cout << "Reading " << file_list[i] << endl;
          TIter next(iF->GetListOfKeys());
          TKey *key = 0;
          while ((key = (TKey*)next()))
          {
               string iClassName = key->GetClassName();
               if( iClassName == "TGraphErrors" )
               {
                   TGraphErrors* iO = ( TGraphErrors* )key->ReadObj();
                   f->cd();
                   iO->Write();
               }
               else if( iClassName == "TTree" )
               {
                  TTree *iT = (TTree*)key->ReadObj();
                  f->cd();
                  iT->CloneTree()->Write();
               }
               iF->cd();
          }
      }
      f->Close();
}
