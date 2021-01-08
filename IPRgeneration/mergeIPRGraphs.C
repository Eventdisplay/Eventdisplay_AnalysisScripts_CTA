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

void mergeIPRGraphs( string iMergedFile = "prod5-ze-20-IPR.root",
                     string iUnMergedFileDirectory = "./" )
{
     TFile *f = new TFile( iMergedFile.c_str(), "RECREATE" );
     if( f->IsZombie() )
     {
         cout << "Error creating new IPR graph file " << iMergedFile << endl;
         return;
     }

     vector< string > fTelTypes;
     fTelTypes.push_back( "lst" );
     fTelTypes.push_back( "mst-fc" );
     fTelTypes.push_back( "mst-nc" );
     fTelTypes.push_back( "sst" );

     string moon = "";
     if (iMergedFile.find("halfmoon") != std::string::npos) {
         moon = "-halfmoon";
     }
     string ze = "20";
     if (iMergedFile.find("60") != std::string::npos) {
         ze = "60";
     }

     for( unsigned int i = 0; i < fTelTypes.size(); i++ )
     {
          string iName = iUnMergedFileDirectory + "./pedestals-" + fTelTypes[i] + moon + "-ze-" + ze + ".root";
          TFile *iF = new TFile( iName.c_str() );
          if( iF->IsZombie() )
          {
              continue;
          }
          cout << "Reading " << iName << endl;
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

