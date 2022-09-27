using System;
using System.IO;
using System.IO.Compression;
using System.Threading.Tasks;
using Flurl.Http;
using UnityEditor;
using UnityEngine;

public class ZipAndUploadHandler
{
    private struct FurioosDeploymentInfo
    {
        public string ApplicationPath;
        public string BinaryID;
        public string ZipFileName;
        public string APIToken;
    }

    public static void PostExport(string exportPath)
    {
        
#if UNITY_CLOUD_BUILD

        var fileInfo = new FileInfo(exportPath);
        string fBinaryId = Environment.GetEnvironmentVariable("FURIOOS_BINARY_ID");
        string fApiToken = Environment.GetEnvironmentVariable("FURIOOS_API_TOKEN");
        string fZipFileName = Environment.GetEnvironmentVariable("FURIOOS_ZIP_FILE_NAME"); 


        var furioosDeployment = new FurioosDeploymentInfo()
        {
            ApplicationPath = fileInfo.DirectoryName,
            BinaryID = fBinaryId,
            APIToken = fApiToken,
            ZipFileName = fZipFileName,
        };
     
        DeployToFurioos(furioosDeployment);
#endif

    }

    
    private static async void DeployToFurioos(FurioosDeploymentInfo furioosDeploymentInfo)
    {
        bool zipCreated = CreateZipBundleFromBuild(furioosDeploymentInfo.ApplicationPath, furioosDeploymentInfo.ZipFileName);
        if (zipCreated) await UploadApplicationBinaryFlurl(furioosDeploymentInfo.ZipFileName, furioosDeploymentInfo.BinaryID, furioosDeploymentInfo.APIToken);
    }
    
    private static bool CreateZipBundleFromBuild(string buildDirectory, string pathZipFile)
    {

        if (File.Exists(pathZipFile))
            File.Delete(pathZipFile);
        try
        {
            Debug.Log("Create zip file from directory: " + buildDirectory);
            ZipFile.CreateFromDirectory(buildDirectory, pathZipFile);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static async Task<FsApplicationBinary> UploadApplicationBinaryFlurl(string filePath, string binaryID, string apitoken)
    {
       
            string uri = "https://api.furioos.com/v1/applicationbinaries/" + binaryID + "/upload";
            FileStream fsFile = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            
            var response = await uri.AllowAnyHttpStatus()
                .WithOAuthBearerToken(apitoken)
                .WithTimeout(1 * 60 * 60) // 1 hour timeout                                
                .PostMultipartAsync(mp => mp
                    .AddFile("file", fsFile, filePath, "application/zip")
                );
            
          
            if (response.StatusCode != 200)
            {
                var result = await response.GetStringAsync();
                Debug.LogWarning(result);
                return null;
            }
            Debug.Log("status code: " + response.StatusCode);
            return await response.GetJsonAsync<FsApplicationBinary>();
    }
}