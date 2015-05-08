require 'gop_data_trust_adapter/type/base'

require 'gop_data_trust_adapter/type/string'
require 'gop_data_trust_adapter/type/number'
require 'gop_data_trust_adapter/type/date'
require 'gop_data_trust_adapter/type/date_time'

module GopDataTrustAdapter

  class Table

    # Can't use * for select, so must present default fields,
    # or always require select. Used their default fields for
    # quick search.
    DEFAULT_FIELDS = [
      :firstname, :middlename, :lastname,
      :sex, :dateofbirth, :emailaddress, :phonenumber,
      :reg_addressline1, :reg_addressline2,
      :reg_addressstate, :reg_addresszip5, :reg_addresszip4,
      :rnc_regid, :party, :rnccalcparty, :statevoteridnumber
    ]

    # Please note for now all numbers in the datatrust
    # appear to be ints.
    TYPE_CONVERSION = {
      :string => GopDataTrustAdapter::Type::String,
      :number => GopDataTrustAdapter::Type::Number,
      :datetime => GopDataTrustAdapter::Type::DateTime,
      :date => GopDataTrustAdapter::Type::Date
    }

    CLASS_CONVERSION = {
      Date => GopDataTrustAdapter::Type::Date,
      DateTime => GopDataTrustAdapter::Type::DateTime,
      Time => GopDataTrustAdapter::Type::DateTime,
      String => GopDataTrustAdapter::Type::String,
      BigDecimal => GopDataTrustAdapter::Type::Number,
      Float => GopDataTrustAdapter::Type::Number,
      Integer => GopDataTrustAdapter::Type::Number
    }
    CLASS_CONVERSION.default(GopDataTrustAdapter::Type::String)

    # If I have the table definition, might as well
    # create a whitelist.
    COLUMNS = {
      :active => {
        :type => :string
      },
      :addresscity => {
        :type => :string
      },
      :addressline1 => {
        :type => :string
      },
      :addressline2 => {
        :type => :string
      },
      :addressstate => {
        :type => :string
      },
      :addresszip4 => {
        :type => :string
      },
      :addresszip5 => {
        :type => :string
      },
      :age => {
        :type => :number
      },
      :agerange => {
        :type => :string
      },
      :ah_absenteeballottype => {
        :type => :string
      },
      :ah_absenteeharvestkey => {
        :type => :number
      },
      :ah_absenteeharvestkeyhash => {
        :type => :string
      },
      :ah_ballotrequest => {
        :type => :number
      },
      :ah_ballotreturned => {
        :type => :number
      },
      :ah_earlyvoted => {
        :type => :number
      },
      :ah_electionname => {
        :type => :string
      },
      :ah_rowcreatedate => {
        :type => :date
      },
      :ah_rowcreatedatetime => {
        :type => :datetime
      },
      :ah_rowupdatedate => {
        :type => :date
      },
      :ah_rowupdatedatetime => {
        :type => :datetime
      },
      :ah_stateabbreviation => {
        :type => :string
      },
      :ah_voterkey => {
        :type => :number
      },
      :answer => {
        :type => :string
      },
      :apartment => {
        :type => :string
      },
      :apartmentnumber => {
        :type => :string
      },
      :cd_contactkey => {
        :type => :number
      },
      :cd_rowcreatedatetime => {
        :type => :datetime
      },
      :cd_rowupdatedatetime => {
        :type => :datetime
      },
      :censusblock => {
        :type => :string
      },
      :citycouncil => {
        :type => :string
      },
      :closeddate => {
        :type => :string
      },
      :con_ageinputindividualdefaultto1stindiv => {
        :type => :string
      },
      :con_antiques => {
        :type => :string
      },
      :con_ap000645publicactivitieswrittenorca => {
        :type => :string
      },
      :con_ap000649attendedapoliticalrallyspee => {
        :type => :string
      },
      :con_ap000650attendedapublicmeetingontow => {
        :type => :string
      },
      :con_ap000654signedapublicorcivicpetitio => {
        :type => :string
      },
      :con_ap000655workedforapoliticalpartyran => {
        :type => :string
      },
      :con_ap001484readadailynewspaperrankbase => {
        :type => :string
      },
      :con_ap001485readanyonedailynewspaperran => {
        :type => :string
      },
      :con_ap001486readanytwodailynewspapersra => {
        :type => :string
      },
      :con_ap001487readanysundaynewspaperrankb => {
        :type => :string
      },
      :con_ap001489healthmagazinesinterestrank => {
        :type => :string
      },
      :con_ap001491listentoradioathomeduringth => {
        :type => :string
      },
      :con_ap001579itrustnewspapermediathemost => {
        :type => :string
      },
      :con_ap001580itrusttvmediathemostrankbas => {
        :type => :string
      },
      :con_ap001581mediatrustedthemostmagazine => {
        :type => :string
      },
      :con_ap001716contributetopublicbroadcast => {
        :type => :string
      },
      :con_ap001717contributetonationalpublicr => {
        :type => :string
      },
      :con_ap001718contributetoareligiousorgan => {
        :type => :string
      },
      :con_ap001719contributetoanonreligiousor => {
        :type => :string
      },
      :con_ap001720havebeenanactivememberofany => {
        :type => :string
      },
      :con_ap001721participatedinenvironmental => {
        :type => :string
      },
      :con_ap001722engagedinfundraisingactivit => {
        :type => :string
      },
      :con_ap001723potentialtobepublicallyorci => {
        :type => :string
      },
      :con_ap001724makecharitablecontributions => {
        :type => :string
      },
      :con_ap002716socialinfluencerrankbase20a => {
        :type => :string
      },
      :con_ap002717sociallyinfluencedrankbase2 => {
        :type => :string
      },
      :con_ap002718mobilesocialnetworkerrankba => {
        :type => :string
      },
      :con_ap002719heavyfacebookuserrankbase20 => {
        :type => :string
      },
      :con_ap002720heavytwitteruserrankbase20a => {
        :type => :string
      },
      :con_ap002721heavylinkeduserrankbase20ap => {
        :type => :string
      },
      :con_ap002722heavyyoutubeuserrankbase20a => {
        :type => :string
      },
      :con_ap004338hasahouseholdmembershipinan => {
        :type => :string
      },
      :con_ap004339hasahouseholdmembershipinco => {
        :type => :string
      },
      :con_ap004349stronglydisagreebigindustri => {
        :type => :string
      },
      :con_ap004350stronglyagreepeopleshouldbe => {
        :type => :string
      },
      :con_ap004353veryinterestedincurrentaffa => {
        :type => :string
      },
      :con_ap004356stronglyagreewiththestateme => {
        :type => :string
      },
      :con_ap004358holdsliberalpoliticalviewsa => {
        :type => :string
      },
      :con_ap004359holdsconservativepoliticalv => {
        :type => :string
      },
      :con_ap004360holdsneutralpoliticalviewsa => {
        :type => :string
      },
      :con_ap004361affiliatedwiththedemocratic => {
        :type => :string
      },
      :con_ap004362affiliatedwiththerepublican => {
        :type => :string
      },
      :con_art => {
        :type => :string
      },
      :con_artsandantiquessc => {
        :type => :string
      },
      :con_autoenthusiast => {
        :type => :string
      },
      :con_automotive => {
        :type => :string
      },
      :con_automotiveautopartsandaccessoriessc => {
        :type => :string
      },
      :con_autowork => {
        :type => :string
      },
      :con_babycare => {
        :type => :string
      },
      :con_bankcardpresenceinhousehold => {
        :type => :string
      },
      :con_baseballsoftball => {
        :type => :string
      },
      :con_bbqgrillsoutdoordining => {
        :type => :string
      },
      :con_boating => {
        :type => :string
      },
      :con_boatingsailing => {
        :type => :string
      },
      :con_boatowner => {
        :type => :string
      },
      :con_books => {
        :type => :string
      },
      :con_booksreligionandspirituality => {
        :type => :string
      },
      :con_broaderliving => {
        :type => :string
      },
      :con_businessowner => {
        :type => :string
      },
      :con_businessownerinputindividual => {
        :type => :string
      },
      :con_campinghiking => {
        :type => :string
      },
      :con_catowner => {
        :type => :string
      },
      :con_childrensapparel => {
        :type => :string
      },
      :con_childrensinterests => {
        :type => :string
      },
      :con_chiphead => {
        :type => :string
      },
      :con_christianfamilies => {
        :type => :string
      },
      :con_christmas => {
        :type => :string
      },
      :con_cigars => {
        :type => :string
      },
      :con_collectiblesantiques => {
        :type => :string
      },
      :con_collectiblesbaseball => {
        :type => :string
      },
      :con_collectiblescoinsstamps => {
        :type => :string
      },
      :con_collectiblesfootball => {
        :type => :string
      },
      :con_commonliving => {
        :type => :string
      },
      :con_communityinvolvementcausessupported => {
        :type => :string
      },
      :con_computers => {
        :type => :string
      },
      :con_consumerabridgedkey => {
        :type => :string
      },
      :con_consumerelectronics => {
        :type => :string
      },
      :con_consumerprominenceindicator => {
        :type => :string
      },
      :con_cooking => {
        :type => :string
      },
      :con_cookingfoodconnoisseur => {
        :type => :string
      },
      :con_cookingfoodgrouping => {
        :type => :string
      },
      :con_cookinggourmet => {
        :type => :string
      },
      :con_countryoforigincodeetech => {
        :type => :string
      },
      :con_countryoforiginhighdetail => {
        :type => :string
      },
      :con_craftshobbies => {
        :type => :string
      },
      :con_creditcardindicatorbankcardholder => {
        :type => :string
      },
      :con_creditcardindicatorgasdepartmentret => {
        :type => :string
      },
      :con_creditcardindicatorpremiumcardholde => {
        :type => :string
      },
      :con_creditcardindicatortravelandenterta => {
        :type => :string
      },
      :con_creditcardindicatorupscaledepartmen => {
        :type => :string
      },
      :con_cruisevacationspropensity => {
        :type => :string
      },
      :con_culturalartisticliving => {
        :type => :string
      },
      :con_cycling => {
        :type => :string
      },
      :con_dietingweightloss => {
        :type => :string
      },
      :con_dogowner => {
        :type => :string
      },
      :con_donationcontribution => {
        :type => :string
      },
      :con_dwellingtype => {
        :type => :string
      },
      :con_easter => {
        :type => :string
      },
      :con_educationinputindividual => {
        :type => :string
      },
      :con_electronics => {
        :type => :string
      },
      :con_electronicshometheatersystem => {
        :type => :string
      },
      :con_enteringadulthoodinputindividual => {
        :type => :string
      },
      :con_environmentalissues => {
        :type => :string
      },
      :con_equestrian => {
        :type => :string
      },
      :con_ethniccodeetech => {
        :type => :string
      },
      :con_exerciserunningjogging => {
        :type => :string
      },
      :con_fashion => {
        :type => :string
      },
      :con_fishingibe63586358 => {
        :type => :string
      },
      :con_fishingibe78027802 => {
        :type => :string
      },
      :con_fitnessequipment => {
        :type => :string
      },
      :con_foodsnatural => {
        :type => :string
      },
      :con_foodsvegetarian => {
        :type => :string
      },
      :con_foodwines => {
        :type => :string
      },
      :con_gamingcasino => {
        :type => :string
      },
      :con_gardeningibe63796379 => {
        :type => :string
      },
      :con_gardeningibe78177817 => {
        :type => :string
      },
      :con_genderinputindividual => {
        :type => :string
      },
      :con_giftsholidayitemssc => {
        :type => :string
      },
      :con_golfibe64226422 => {
        :type => :string
      },
      :con_golfibe78117811 => {
        :type => :string
      },
      :con_grandchildren => {
        :type => :string
      },
      :con_greenliving => {
        :type => :string
      },
      :con_gunsandammunition => {
        :type => :string
      },
      :con_healthandbeautysc => {
        :type => :string
      },
      :con_healthdiabeticinterestinhh => {
        :type => :string
      },
      :con_healthhomeopathicinterestinhh => {
        :type => :string
      },
      :con_healthmedical => {
        :type => :string
      },
      :con_healthseniorneedsinterestinhh => {
        :type => :string
      },
      :con_highbrow => {
        :type => :string
      },
      :con_highlylikelyinvestors => {
        :type => :string
      },
      :con_hightechliving => {
        :type => :string
      },
      :con_hispaniclanguagepreference => {
        :type => :string
      },
      :con_historymilitary => {
        :type => :string
      },
      :con_homeandgarden => {
        :type => :string
      },
      :con_homeassessedvalueactualrp => {
        :type => :string
      },
      :con_homebedroomcountrp => {
        :type => :string
      },
      :con_homecare => {
        :type => :string
      },
      :con_homeimprovement => {
        :type => :string
      },
      :con_homeimprovementdoityourselfers => {
        :type => :string
      },
      :con_homelengthofresidenceactualrpibe858 => {
        :type => :string
      },
      :con_homelengthofresidenceactualrpibe975 => {
        :type => :string
      },
      :con_homeloanamountoriginalactualrp => {
        :type => :string
      },
      :con_homelotsquarefootageactualrp => {
        :type => :string
      },
      :con_homemarketvalueestimatedactualrp => {
        :type => :string
      },
      :con_homeownerrenter => {
        :type => :string
      },
      :con_homepoolpresent => {
        :type => :string
      },
      :con_homepropertytype => {
        :type => :string
      },
      :con_homepurchaseyearyyyy => {
        :type => :string
      },
      :con_homevideorecording => {
        :type => :string
      },
      :con_homeyearbuiltactualrp => {
        :type => :string
      },
      :con_householdsizeplus => {
        :type => :string
      },
      :con_hunting => {
        :type => :string
      },
      :con_huntingshooting => {
        :type => :string
      },
      :con_incomeestimatedhousehold => {
        :type => :string
      },
      :con_investingactive => {
        :type => :string
      },
      :con_investmentsrealestate => {
        :type => :string
      },
      :con_investmentsstocksbonds => {
        :type => :string
      },
      :con_jewelry => {
        :type => :string
      },
      :con_languagepreferencecodeetech => {
        :type => :string
      },
      :con_lifeinsurancepolicyowner => {
        :type => :string
      },
      :con_likelyinvestors => {
        :type => :string
      },
      :con_magazinesfashion => {
        :type => :string
      },
      :con_magazinesfoodcooking => {
        :type => :string
      },
      :con_magazineswomensinterest => {
        :type => :string
      },
      :con_mailorderbuyercategoriesmerchandise => {
        :type => :string
      },
      :con_maritalstatusinthehousehold => {
        :type => :string
      },
      :con_maritalstatusplus => {
        :type => :string
      },
      :con_mediachannelusagecellphone => {
        :type => :string
      },
      :con_mediachannelusagedaytimetv => {
        :type => :string
      },
      :con_mediachannelusageinternet => {
        :type => :string
      },
      :con_mediachannelusageprimetimetv => {
        :type => :string
      },
      :con_mediachannelusageradio => {
        :type => :string
      },
      :con_membershipclubswine => {
        :type => :string
      },
      :con_mensapparelaccessories => {
        :type => :string
      },
      :con_mensapparelbusinessbusinesscasual => {
        :type => :string
      },
      :con_mensapparelcasual => {
        :type => :string
      },
      :con_mensapparelfootwear => {
        :type => :string
      },
      :con_miavghhldincome => {
        :type => :string
      },
      :con_mimedagepop => {
        :type => :string
      },
      :con_mimedhomevalueownroccup => {
        :type => :string
      },
      :con_mipercadltfemalesemployed16plus => {
        :type => :string
      },
      :con_mipercadltfemalesinlaborforce16plus => {
        :type => :string
      },
      :con_mipercadltmalesemployed16plus => {
        :type => :string
      },
      :con_mipercadltmalesinlaborforce16plus => {
        :type => :string
      },
      :con_mipercadltvetsage18plus => {
        :type => :string
      },
      :con_mipercage3plusenrollincollege => {
        :type => :string
      },
      :con_mipercapitaincome => {
        :type => :string
      },
      :con_mipercasianspeaking => {
        :type => :string
      },
      :con_mipercblack => {
        :type => :string
      },
      :con_mipercchildwithnoparentinlf => {
        :type => :string
      },
      :con_mipercchildwithsinglemominlf => {
        :type => :string
      },
      :con_mipercconstrandextractionjobs => {
        :type => :string
      },
      :con_mipercemployedbyfedgov => {
        :type => :string
      },
      :con_mipercemployedbylocalgov => {
        :type => :string
      },
      :con_mipercemployedbystgov => {
        :type => :string
      },
      :con_mipercemployedinagriculture => {
        :type => :string
      },
      :con_mipercenglishspeakingonly => {
        :type => :string
      },
      :con_mipercforeignborn => {
        :type => :string
      },
      :con_miperchealthcaresupportjob => {
        :type => :string
      },
      :con_miperchhldsfoodstampspastyear => {
        :type => :string
      },
      :con_miperchhldsincome125000to149999 => {
        :type => :string
      },
      :con_miperchhldsincome150000ormore => {
        :type => :string
      },
      :con_miperchhldsincome15000to24999 => {
        :type => :string
      },
      :con_miperchhldsincomeles15000 => {
        :type => :string
      },
      :con_miperchispanicorigin => {
        :type => :string
      },
      :con_mipercmarried => {
        :type => :string
      },
      :con_mipercmarriedcplefamilies => {
        :type => :string
      },
      :con_mipercmomsemployed16pluswchildun18 => {
        :type => :string
      },
      :con_mipercownroccup => {
        :type => :string
      },
      :con_mipercrenteroccup => {
        :type => :string
      },
      :con_mipercsnglparenthhld => {
        :type => :string
      },
      :con_mipercspanishspeakingonly => {
        :type => :string
      },
      :con_mipercusingpubtrans => {
        :type => :string
      },
      :con_mipercvacanthsing => {
        :type => :string
      },
      :con_mipercwhite => {
        :type => :string
      },
      :con_miplusmedgrossrent => {
        :type => :string
      },
      :con_miplusperc2parentearnerfamily => {
        :type => :string
      },
      :con_miplusperccivninswmedicareinsurance => {
        :type => :string
      },
      :con_miplusperccivninswnoinsurance => {
        :type => :string
      },
      :con_miplusperccivninswprivinsurance => {
        :type => :string
      },
      :con_mipluspercenrollchldinpubelemhighsc => {
        :type => :string
      },
      :con_miplusperchhldsbelowpovertylevel => {
        :type => :string
      },
      :con_miplusperchhldsnoveh => {
        :type => :string
      },
      :con_miplusperchhldswchild => {
        :type => :string
      },
      :con_mipluspercsinglefemalehhldwrelchild => {
        :type => :string
      },
      :con_mipluspercsnglmomwchildinlaborforce => {
        :type => :string
      },
      :con_mipluspercusingbicycle => {
        :type => :string
      },
      :con_mipluspercwalking => {
        :type => :string
      },
      :con_motorcycles => {
        :type => :string
      },
      :con_motorcycling => {
        :type => :string
      },
      :con_musicavidlistener => {
        :type => :string
      },
      :con_musicchristianandgospel => {
        :type => :string
      },
      :con_nascar => {
        :type => :string
      },
      :con_networth => {
        :type => :string
      },
      :con_numberofchildrenplus => {
        :type => :string
      },
      :con_numberoflinesofcredittradecounter => {
        :type => :string
      },
      :con_occupation1stindividual => {
        :type => :string
      },
      :con_occupationinputindividual => {
        :type => :string
      },
      :con_onlinepurchasingindicator => {
        :type => :string
      },
      :con_otherpetowner => {
        :type => :string
      },
      :con_ournationsheritage => {
        :type => :string
      },
      :con_outdoorsgrouping => {
        :type => :string
      },
      :con_parenting => {
        :type => :string
      },
      :con_patrioticholidaystheme => {
        :type => :string
      },
      :con_pcoperatingsystem => {
        :type => :string
      },
      :con_pcsoftwarebuyer => {
        :type => :string
      },
      :con_personkey => {
        :type => :string
      },
      :con_presenceofchildrenplusnew => {
        :type => :string
      },
      :con_professionalliving => {
        :type => :string
      },
      :con_religiousaffiliationcodeetech => {
        :type => :string
      },
      :con_retailpurchasescategoriesstandardre => {
        :type => :string
      },
      :con_rfmtotaldollarsspent => {
        :type => :string
      },
      :con_rollupcodeetech => {
        :type => :string
      },
      :con_selfimprovement => {
        :type => :string
      },
      :con_singleparent => {
        :type => :string
      },
      :con_skiing => {
        :type => :string
      },
      :con_snowskiing => {
        :type => :string
      },
      :con_spectatorsportsbaseball => {
        :type => :string
      },
      :con_spectatorsportsbasketball => {
        :type => :string
      },
      :con_spectatorsportsfootball => {
        :type => :string
      },
      :con_sportsandleisurec => {
        :type => :string
      },
      :con_sweepstakescontests => {
        :type => :string
      },
      :con_swimmingpools => {
        :type => :string
      },
      :con_technographicsegmentpropensitytechn => {
        :type => :string
      },
      :con_tennis => {
        :type => :string
      },
      :con_textmessaging => {
        :type => :string
      },
      :con_tools => {
        :type => :string
      },
      :con_traveldomestic => {
        :type => :string
      },
      :con_travelinternational => {
        :type => :string
      },
      :con_tvcable => {
        :type => :string
      },
      :con_upscaleliving => {
        :type => :string
      },
      :con_vacationtravelcruisehavetaken => {
        :type => :string
      },
      :con_valuepricedgeneralmerchandise => {
        :type => :string
      },
      :con_vehicledominantlifestyleindicator => {
        :type => :string
      },
      :con_vehiclenewcarbuyer => {
        :type => :string
      },
      :con_vehicletruckmotorcyclervownermotorc => {
        :type => :string
      },
      :con_vehicletruckmotorcyclervownerrvowne => {
        :type => :string
      },
      :con_vehicletruckmotorcyclervownertrucko => {
        :type => :string
      },
      :con_veteran => {
        :type => :string
      },
      :con_videogames => {
        :type => :string
      },
      :con_wirelesscellularphoneowner => {
        :type => :string
      },
      :con_womensapparelaccessories => {
        :type => :string
      },
      :con_womensapparelbusinessbusinesscasual => {
        :type => :string
      },
      :con_womensapparelcasual => {
        :type => :string
      },
      :con_womensappareleveningwear => {
        :type => :string
      },
      :con_womensapparelfootwear => {
        :type => :string
      },
      :con_womensplussizes => {
        :type => :string
      },
      :con_woodworking => {
        :type => :string
      },
      :con_workingwoman => {
        :type => :string
      },
      :con_yoga => {
        :type => :string
      },
      :congressionaldistrict => {
        :type => :string
      },
      :contactdate => {
        :type => :string
      },
      :contactdetailskey => {
        :type => :number
      },
      :contactdisposition => {
        :type => :string
      },
      :contactkey => {
        :type => :number
      },
      :contacttime => {
        :type => :string
      },
      :contacttype => {
        :type => :string
      },
      :countycommissioner => {
        :type => :string
      },
      :countyname => {
        :type => :string
      },
      :ct_rowcreatedatetime => {
        :type => :datetime
      },
      :ct_rowupdatedatetime => {
        :type => :datetime
      },
      :ct_stateabbreviation => {
        :type => :string
      },
      :dataelementsrowcreate => {
        :type => :string
      },
      :dateofbirth => {
        :type => :date,
        :format => :no_dash
      },
      :de_stateabbreviation => {
        :type => :string
      },
      :de_voterkey => {
        :type => :number
      },
      :dmacode => {
        :type => :string
      },
      :electioncode => {
        :type => :string
      },
      :electionname => {
        :type => :string
      },
      :elementdescription => {
        :type => :string
      },
      :elementgroupname => {
        :type => :string
      },
      :elementname => {
        :type => :string
      },
      :elementyear => {
        :type => :string
      },
      :email_rowcreatedatetime => {
        :type => :datetime
      },
      :emailaddress => {
        :type => :string
      },
      :firstname => {
        :type => :string
      },
      :housenumber => {
        :type => :string
      },
      :housenumbersuffix => {
        :type => :string
      },
      :initiativename => {
        :type => :string
      },
      :iswireless => {
        :type => :string
      },
      :judicial => {
        :type => :string
      },
      :jurisdictioncode => {
        :type => :string
      },
      :jurisdictionname => {
        :type => :string
      },
      :lastname => {
        :type => :string
      },
      :latitude => {
        :type => :string
      },
      :localvoteridnumber => {
        :type => :string
      },
      :longitude => {
        :type => :string
      },
      :mail_addresscity => {
        :type => :string
      },
      :mail_addressline1 => {
        :type => :string
      },
      :mail_addressline2 => {
        :type => :string
      },
      :mail_addressstate => {
        :type => :string
      },
      :mail_addresszip4 => {
        :type => :string
      },
      :mail_addresszip5 => {
        :type => :string
      },
      :mail_apartment => {
        :type => :string
      },
      :mail_apartmentnumber => {
        :type => :string
      },
      :mail_censusblock => {
        :type => :string
      },
      :mail_housenumber => {
        :type => :string
      },
      :mail_housenumbersuffix => {
        :type => :string
      },
      :mail_latitude => {
        :type => :string
      },
      :mail_longitude => {
        :type => :string
      },
      :mail_rowcreatedatetime => {
        :type => :datetime
      },
      :mail_rowupdatedatetime => {
        :type => :datetime
      },
      :mail_streetname => {
        :type => :string
      },
      :mail_streetpostdirection => {
        :type => :string
      },
      :mail_streetprefix => {
        :type => :string
      },
      :mail_streettype => {
        :type => :string
      },
      :mailingaddressncoacode => {
        :type => :string
      },
      :mailingaddressncoadate => {
        :type => :string
      },
      :mediamarket => {
        :type => :string
      },
      :microtargetingkey => {
        :type => :number
      },
      :microtargetingmodelname => {
        :type => :string
      },
      :microtargetingprojectname => {
        :type => :string
      },
      :microtargetingsegment => {
        :type => :number
      },
      :microtargetingsegmentname => {
        :type => :string
      },
      :middlename => {
        :type => :string
      },
      :mt_congressionaldistrict => {
        :type => :string
      },
      :mt_rowcreatedatetime => {
        :type => :datetime
      },
      :mt_stateabbreviation => {
        :type => :string
      },
      :mt_voterkey => {
        :type => :number
      },
      :nameprefix => {
        :type => :string
      },
      :namesuffix => {
        :type => :string
      },
      :nickname => {
        :type => :string
      },
      :oc_rowcreatedatetime => {
        :type => :datetime
      },
      :officename => {
        :type => :string
      },
      :park => {
        :type => :string
      },
      :party => {
        :type => :string
      },
      :per_rowcreatedatetime => {
        :type => :datetime
      },
      :per_rowupdatedatetime => {
        :type => :datetime
      },
      :per_stateabbreviation => {
        :type => :string
      },
      :permanentabsentee => {
        :type => :string
      },
      :pg_rowcreatedatetime => {
        :type => :datetime
      },
      :pg_rowupdatedatetime => {
        :type => :datetime
      },
      :ph_rowcreatedatetime => {
        :type => :datetime
      },
      :ph_rowupdatedatetime => {
        :type => :datetime
      },
      :phonehasdonotcallflag => {
        :type => :string
      },
      :phonematchlevel => {
        :type => :string
      },
      :phonenumber => {
        :type => :string
      },
      :phonereliabilityscore => {
        :type => :string
      },
      :phonesource => {
        :type => :string
      },
      :politicalgeographykey => {
        :type => :number
      },
      :politicalgeographykeyhash => {
        :type => :string
      },
      :precinct => {
        :type => :string
      },
      :precinctname => {
        :type => :string
      },
      :precinctsubdistrict => {
        :type => :string
      },
      :question => {
        :type => :string
      },
      :race => {
        :type => :string
      },
      :reg_addresscity => {
        :type => :string
      },
      :reg_addressline1 => {
        :type => :string
      },
      :reg_addressline2 => {
        :type => :string
      },
      :reg_addressstate => {
        :type => :string
      },
      :reg_addresszip4 => {
        :type => :string
      },
      :reg_addresszip5 => {
        :type => :string
      },
      :reg_apartment => {
        :type => :string
      },
      :reg_apartmentnumber => {
        :type => :string
      },
      :reg_censusblock => {
        :type => :string
      },
      :reg_housenumber => {
        :type => :string
      },
      :reg_housenumbersuffix => {
        :type => :string
      },
      :reg_latitude => {
        :type => :string
      },
      :reg_longitude => {
        :type => :string
      },
      :reg_rowcreatedatetime => {
        :type => :datetime
      },
      :reg_rowupdatedatetime => {
        :type => :datetime
      },
      :reg_streetname => {
        :type => :string
      },
      :reg_streetpostdirection => {
        :type => :string
      },
      :reg_streetprefix => {
        :type => :string
      },
      :reg_streettype => {
        :type => :string
      },
      :registrationcloseddate => {
        :type => :string
      },
      :registrationdate => {
        :type => :number,
        :format => :no_dash
      },
      :rnc_regid => {
        :type => :string
      },
      :rnccalcparty => {
        :type => :string
      },
      :rncid => {
        :type => :number
      },
      :rowcreatedatetime => {
        :type => :datetime
      },
      :rowupdatedatetime => {
        :type => :datetime
      },
      :schoolboard => {
        :type => :string
      },
      :schooldistrict => {
        :type => :string
      },
      :sex => {
        :type => :string
      },
      :source => {
        :type => :string
      },
      :stateabbreviation => {
        :type => :string
      },
      :statecountyfips => {
        :type => :string
      },
      :statelowerhousedistrict => {
        :type => :string
      },
      :statelowerhousesubdistrict => {
        :type => :string
      },
      :statesenatedistrict => {
        :type => :string
      },
      :statevoteridnumber => {
        :type => :string
      },
      :streetname => {
        :type => :string
      },
      :streetpostdirection => {
        :type => :string
      },
      :streetprefix => {
        :type => :string
      },
      :streettype => {
        :type => :string
      },
      :tagname => {
        :type => :string
      },
      :targetaddresskey => {
        :type => :number
      },
      :targetemailkey => {
        :type => :number
      },
      :targetpersonkey => {
        :type => :number
      },
      :targetphonekey => {
        :type => :number
      },
      :universename => {
        :type => :string
      },
      :vh_rowcreatedatetime => {
        :type => :datetime
      },
      :vh_rowupdatedatetime => {
        :type => :datetime
      },
      :vh_voterkey => {
        :type => :number
      },
      :vote => {
        :type => :string
      },
      :votemethod => {
        :type => :string
      },
      :voteparty => {
        :type => :string
      },
      :voterkey => {
        :type => :number
      },
      :vp_rowcreatedatetime => {
        :type => :datetime
      },
      :vp_rowupdatedatetime => {
        :type => :datetime
      },
      :vp_voterkey => {
        :type => :number
      },
      :vtr_countyname => {
        :type => :string
      },
      :vtr_rowcreatedatetime => {
        :type => :datetime
      },
      :vtr_rowupdatedatetime => {
        :type => :datetime
      },
      :vtr_stateabbreviation => {
        :type => :string
      },
      :vtr_statecountyfips => {
        :type => :string
      },
      :ward => {
        :type => :string
      },
      :water => {
        :type => :string
      },
      :addresskey => {
        :type => :number
      },
      :addresskeyhash => {
        :type => :string
      },
      :clientcontactpersonkey => {
        :type => :number
      },
      :clientname => {
        :type => :string
      },
      :columntype => {
        :type => :string
      },
      :contactdetailshash => {
        :type => :string
      },
      :contactkeyhash => {
        :type => :string
      },
      :contactpersonkey => {
        :type => :number
      },
      :dataelementkey => {
        :type => :number
      },
      :dataelementskeyhash => {
        :type => :string
      },
      :de_personkey => {
        :type => :number
      },
      :description => {
        :type => :string
      },
      :dqlcontraint => {
        :type => :string
      },
      :dqlfieldmappingkey => {
        :type => :number
      },
      :emailkey => {
        :type => :number
      },
      :fieldname => {
        :type => :string
      },
      :history_fields => {
        :type => :string
      },
      :insert_fields => {
        :type => :string
      },
      :ipconstraint => {
        :type => :string
      },
      :isprimary => {
        :type => :string
      },
      :isvalid => {
        :type => :string
      },
      :limit => {
        :type => :number
      },
      :mail_addresskey => {
        :type => :number
      },
      :mail_addresskeyhash => {
        :type => :string
      },
      :mail_rncaddresskey => {
        :type => :number
      },
      :mailingaddresskey => {
        :type => :number
      },
      :microtargetingkeyhash => {
        :type => :string
      },
      :oc_clientkey => {
        :type => :number
      },
      :oc_dqlconstraint => {
        :type => :string
      },
      :oc_history_fields => {
        :type => :string
      },
      :oc_insert_fields => {
        :type => :string
      },
      :oc_isvalid => {
        :type => :string
      },
      :oc_limit => {
        :type => :number
      },
      :oc_organizationkey => {
        :type => :number
      },
      :oc_read_fields => {
        :type => :string
      },
      :oc_removefields => {
        :type => :string
      },
      :oc_suggest_fields => {
        :type => :string
      },
      :oc_update_fields => {
        :type => :string
      },
      :organizationclientskey => {
        :type => :number
      },
      :organizationclienttoken => {
        :type => :string
      },
      :organizationkey => {
        :type => :number
      },
      :organizationname => {
        :type => :string
      },
      :organizationtoken => {
        :type => :string
      },
      :personkey => {
        :type => :number
      },
      :personkeyhash => {
        :type => :string
      },
      :phonekey => {
        :type => :number
      },
      :primaryaddresskey => {
        :type => :number
      },
      :primaryemailkey => {
        :type => :number
      },
      :primaryphonekey => {
        :type => :number
      },
      :read_fields => {
        :type => :string
      },
      :reg_addresskey => {
        :type => :number
      },
      :reg_addresskeyhash => {
        :type => :string
      },
      :reg_rncaddresskey => {
        :type => :number
      },
      :registrationaddresskey => {
        :type => :number
      },
      :remove_fields => {
        :type => :string
      },
      :rnc_voterkey => {
        :type => :number
      },
      :rncaddresskey => {
        :type => :number
      },
      :suggest_fields => {
        :type => :string
      },
      :tablename => {
        :type => :string
      },
      :update_fields => {
        :type => :string
      },
      :voterkeyhash => {
        :type => :string
      },
      :vp_phonekey => {
        :type => :number
      },
      :vtr_emailkey => {
        :type => :number
      },
      :vtr_personkey => {
        :type => :number
      },
      :vtr_politicalgeographykey => {
        :type => :number
      },
    }

    def self.columns
      COLUMNS
    end

    def self.type_conversion
      TYPE_CONVERSION
    end

    def self.class_conversion
      CLASS_CONVERSION
    end

    def self.default_fields
      DEFAULT_FIELDS
    end

    def self.[] _attr
      OpenStruct.new(COLUMNS[_attr])
    end

  end

end