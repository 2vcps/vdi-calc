#Something I do a lot- Jon Owings
#VMware View and Citrix VDI Calculator 
require 'rubygems'
require 'sinatra'


ioPerBlock = 8200.00
diskOvr = 0.91

maxDM_5300 = 2
maxDM_5500 = 3
maxDM_5700 = 4
maxDM_7500 = 8
max1rg_1TB = 9940
max1rg_2TB = 19880
max1rg_3TB = 29820

get '/' do
	erb :index
end

get '/calc_home' do
    @vdicalc=params[:vditype]
    @avgRam=params[:avgRam]
    @memRes=params[:memRes]
    @nDesktops=params[:nDesktops]
    @ioSteady=params[:ioSteady]
    @baseImg=params[:baseImg]
    @custIO= @nDesktops.to_f * @ioSteady.to_f
    @conCurr=params[:conCurr]
    @userData=params[:userData]
    @adjuserData= @userData.to_i * @nDesktops.to_i 
    @addStor=params[:addStor]
    @storProto=params[:storProto]
    @userDataType=params[:userDataType]
    @diskPer=(@vditype == "Citrix PVS" ? "16" : "15")
    @maxConCurr = @nDesktops.to_f * (@conCurr.to_f/100)
    @numBlk= @custIO / ioPerBlock
    @adjNumBlk= @numBlk.ceil
    @hsFlash= (@adjNumBlk * 2)/30
    @hsFlashUp= (@hsFlash > 1 ? 2 : 1) 
    @numFlash= (@adjNumBlk * 2) + @hsFlashUp
    @numSAS= (@diskPer.to_f * @adjNumBlk).to_i
    @capReq= ((@avgRam.to_f * (@memRes.to_f/100)) + @maxLC.to_f) * @nDesktops.to_f
    @hsSAS= @numSAS/30
    @hsSASUp= @hsSAS.ceil
    @numSAS= @diskPer.to_f * @adjNumBlk + @hsSASUp
    @driveType= (@maxLC.to_f < 3 ? "300" : "600")
    @dMover= @custIO/12300 + 1
    @adjMover= @dMover.ceil
    @dispMover= (@storProto == "NFS" ? @adjMover : "None")
    #@userDataType=(@adjuserData.to_i <= 9940 ? "1TB" : "2TB")
    #@userDataType=(@adjuserData.to_i >= 29820 ? "3TB" : @userDataType)
    @userDTnum=(@userDataType == "1TB" ? 1024 : 2048)
    @userDTnum=(@userDataType == "3TB" ? 3072 : 900)
    @userDiskRaid=(@userDataType == "1TB" ? 16 : 5)
    @userDiskRaid=(@userDataType == "2TB" ? 16 : @userDiskRaid)
    @userDiskRaid=(@userDataType == "3TB" ? 16 : @userDiskRaid)
    @userDiskRaidPenalty=(@userDiskRaid == "16" ? 2 : 1)
    @numuserRG= (@adjuserData.to_f / (@userDTnum * (@userDiskRaid - @userDiskRaidPenalty) * 0.71)).ceil
    @userDataNum= @userDiskRaid * @numuserRG
    @userDataNum=(@userData.to_i == 0 ? 0 : @userDataNum)
    @userDataHS = (@userDataNum.to_f/30).ceil
    @totaluserDataNum= @userDataNum + @userDataHS
    @totalDriveCount= @numSAS + @numFlash + @totaluserDataNum
    @vnxType= (@nDesktops.to_i < 1501 ? "VNX5300" : "VNX5500")
    @vnxType= (@nDesktops.to_i > 3000 ? "VNX5700" : @vnxType)
    @vnxType= (@nDesktops.to_i > 4500 ? "VNX7500" : @vnxType)
    @vnxType= (@nDesktops.to_i > 7500 ? "Use Multiple VNX Arrays" : @vnxType)
    @adjvnxType= (@adjMover.to_i == 2 ? "VNX5300" : "VNX5300")
    @adjvnxType= (@adjMover.to_i > 2 ? "VNX5500" : @adjvnxType)
    @adjvnxType=(@adjMover.to_i == 4 ? "VNX5700" : @adjvnxType)
    @adjvnxType=(@adjMover.to_i > 4 ? "VNX7500" : @adjvnxType)
    @adjvnxType=(@storProto == "NFS" ? @adjvnxType : "None Needed, FC Selected")
    @maxDrives=(@adjvnxType == "VNX5300" ? 125 : 250)
    @maxDrives=(@adjvnxType == "VNX5500" ? 250 : @maxDrives)
    @maxDrives=(@adjvnxType == "VNX5700" ? 500 : @maxDrives)
    @maxDrives=(@adjvnxType == "VNX7500" ? 1000 : @maxDrives)
    @adjvnxType= (@totalDriveCount <= 125 ? @adjvnxType : "VNX5500" )
    @adjvnxType= (@totalDriveCount >= 250 ? "VNX5700" : @adjvnxType)
    @adjvnxType=(@totalDriveCount >= 500 ? "VNX7500" : @adjvnxType)
    @adjvnxType=(@totalDriveCount > 1000 ? "Error, Total Drives exceeds suggested array Type's maximum" : @adjvnxType)    
    @moreFlash=(@nDesktops.to_i > 1000 && @vnxType == "VNX5300" ? 2 : "None")
    @baseFlashhelp=@adjNumBlk.to_i * 2
    @baseFlash=(@baseImg.to_i < 8 ? "None" : @baseFlashhelp)
    @lic=(@adjuserData.to_i > 0 ? "CIFS" : "No File")
    @lic=(@storProto == "NFS" && @adjuserData.to_i > 0 ? "NFS,CIFS" : @lic)
    erb :calc_home 
end