{
  description = "Flutter Devshell";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";    
  };
  
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };

      androidEnv = pkgs.callPackage "${nixpkgs}/pkgs/development/mobile/androidenv" {
        inherit pkgs;
        licenseAccepted = true;
      };
      androidPkgs = androidEnv.composeAndroidPackages {
        platformVersions = [ "35" ];
        buildToolsVersions = [ "33.0.1" ];
        includeEmulator = "if-supported";
        includeSystemImages = "if-supported";
        includeNDK = "if-supported";
        useGoogleAPIs = true;
        extraLicenses = [
          "android-googletv-license"
          "android-sdk-arm-dbt-license"
          "android-sdk-preview-license"
          "android-sdk-license"
          "google-gdk-license"
          "intel-android-extra-license"
          "intel-android-sysimage-license"
          "mips-android-sysimage-license"
        ];
      };
    in
    {
      devShell.${system} = pkgs.mkShell rec {
        packages = with pkgs; [
          flutter327
          androidPkgs.androidsdk
          androidPkgs.platform-tools
          jdk17
        ];

        JAVA_HOME = pkgs.jdk17.home;
        ANDROID_SDK_ROOT = "${androidPkgs.androidsdk}/libexec/android-sdk";
        ANDROID_NDK_ROOT = "${ANDROID_SDK_ROOT}/ndk-bundle";
        ANDROID_HOME = "${androidPkgs.androidsdk}/libexec/android-sdk";
        NDK_HOME = "${ANDROID_SDK_ROOT}/ndk-bundle";
      };
    };
}
