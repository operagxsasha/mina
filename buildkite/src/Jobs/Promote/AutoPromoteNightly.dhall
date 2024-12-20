-- Auto Promote Nightly is job which should be either used just after nightly run or in separate pipeline
-- Small trick to allow manual override of source version which is about to be promoted
-- If FROM_VERSION_MANUAL is set the used it.
-- Otherwise use MINA_DEB_VERSION which is set in export-git-env-vars.sh file

let Prelude = ../../External/Prelude.dhall

let S = ../../Lib/SelectFiles.dhall

let DebianVersions = ../../Constants/DebianVersions.dhall

let Artifacts = ../../Constants/Artifacts.dhall

let DebianPackage = ../../Constants/DebianPackage.dhall

let DebianChannel = ../../Constants/DebianChannel.dhall

let Network = ../../Constants/Network.dhall

let Profiles = ../../Constants/Profiles.dhall

let JobSpec = ../../Pipeline/JobSpec.dhall

let PipelineTag = ../../Pipeline/Tag.dhall

let Pipeline = ../../Pipeline/Dsl.dhall

let PromotePackages = ../../Command/Promotion/PromotePackages.dhall

let VerifyPackages = ../../Command/Promotion/VerifyPackages.dhall

let Command = ../../Command/Base.dhall

let List/map = Prelude.List.map

let promotePackages =
          \(codenames : List DebianVersions.DebVersion)
      ->  \(network : Network.Type)
      ->  \(target_channel : DebianChannel.Type)
      ->  PromotePackages.PromotePackagesSpec::{
          , debians =
            [ DebianPackage.Type.Daemon
            , DebianPackage.Type.LogProc
            , DebianPackage.Type.Archive
            ]
          , dockers = [ Artifacts.Type.Daemon, Artifacts.Type.Archive ]
          , version = "\\\${FROM_VERSION_MANUAL:-\\\${MINA_DEB_VERSION}}"
          , architecture = "amd64"
          , new_debian_version = "\\\$(date \"+%Y%m%d\")"
          , profile = Profiles.Type.Standard
          , network = network
          , codenames = codenames
          , from_channel = DebianChannel.Type.Unstable
          , to_channel = target_channel
          , new_tags =
            [ "latest-${DebianChannel.lowerName target_channel}-nightly"
            , "${DebianChannel.lowerName
                   target_channel}-nightly-\\\$(date \"+%Y%m%d\")"
            ]
          , remove_profile_from_name = False
          , publish = False
          , depends_on =
              List/map
                DebianVersions.DebVersion
                Command.TaggedKey.Type
                (     \(codename : DebianVersions.DebVersion)
                  ->  { name = "PublishDebians"
                      , key =
                          "publish-${DebianVersions.lowerName codename}-deb-pkg"
                      }
                )
                codenames
          }

let verifyPackages =
      VerifyPackages.VerifyPackagesSpec::{
      , promote_step_name = Some "AutoPromoteNightly"
      , debians =
        [ DebianPackage.Type.Daemon
        , DebianPackage.Type.LogProc
        , DebianPackage.Type.Archive
        ]
      , dockers = [ Artifacts.Type.Daemon, Artifacts.Type.Archive ]
      , new_debian_version = "\\\$(date \"+%Y%m%d\")"
      , profile = Profiles.Type.Standard
      , network = Network.Type.Devnet
      , codenames =
        [ DebianVersions.DebVersion.Bullseye, DebianVersions.DebVersion.Focal ]
      , channel = DebianChannel.Type.Compatible
      , new_tags =
        [ "latest-compatible-nightly"
        , "compatible-nightly-\\\$(date \"+%Y%m%d\")"
        ]
      , remove_profile_from_name = False
      , published = False
      }

let promoteDebiansSpecs =
      PromotePackages.promotePackagesToDebianSpecs
        ( promotePackages
            [ DebianVersions.DebVersion.Focal
            , DebianVersions.DebVersion.Bullseye
            ]
            Network.Type.Devnet
            DebianChannel.Type.Compatible
        )

let promoteDockersSpecs =
      PromotePackages.promotePackagesToDockerSpecs
        ( promotePackages
            [ DebianVersions.DebVersion.Focal
            , DebianVersions.DebVersion.Bullseye
            ]
            Network.Type.Devnet
            DebianChannel.Type.Compatible
        )

let verifyDebiansSpecs =
      VerifyPackages.verifyPackagesToDebianSpecs verifyPackages

let verifyDockersSpecs =
      VerifyPackages.verifyPackagesToDockerSpecs verifyPackages

in  Pipeline.build
      Pipeline.Config::{
      , spec = JobSpec::{
        , dirtyWhen = [ S.everything ]
        , path = "Promote"
        , tags = [ PipelineTag.Type.Promote, PipelineTag.Type.TearDown ]
        , name = "AutoPromoteNightly"
        }
      , steps =
            PromotePackages.promoteSteps promoteDebiansSpecs promoteDockersSpecs
          # VerifyPackages.verificationSteps
              verifyDebiansSpecs
              verifyDockersSpecs
      }
