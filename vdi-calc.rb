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


get '/' do
	erb :index
end

get '/calc_home' do
    @vditype=params[:vditype]
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
    @diskPer=(@vditype == "Citrix PVS" ? "16" : "15")
    @maxConCurr = @nDesktops.to_f * (@conCurr.to_f/100)
    @numBlk= @custIO / ioPerBlock
    @adjNumBlk= @numBlk.ceil
    @hsFlash= (@adjNumBlk * 2)/30
    @hsFlashUp= (@hsFlash > 1 ? 2 : 1) 
    @numFlash= (@adjNumBlk * 2) + @hsFlashUp
    @numSAS= @diskPer.to_f * @adjNumBlk
    @capReq= ((@avgRam.to_f * (@memRes.to_f/100)) + @maxLC.to_f) * @nDesktops.to_f
    @hsSAS= @numSAS/30
    @hsSASUp= @hsSAS.ceil
    @numSAS= @diskPer.to_f * @adjNumBlk + @hsSASUp
    @driveType= (@maxLC.to_f < 3 ? "300" : "600")
    @dMover= @custIO/12300 + 1
    @adjMover= @dMover.ceil
    @dispMover= (@storProto == "NFS" ? @adjMover : "None")
    @userDataType=(@adjuserData.to_i <= 10000 ? "1TB" : "2TB")
    @userDataType=(@adjuserData.to_i >= 30000 ? "3TB" : @userDataType)
    @userDataNum=@adjNumBlk * 16
    @userDataNum=(@userData.to_i == 0 ? 0 : @userDataNum)
    @userDataHS = (@userDataNum.to_f/30).ceil
    @totaluserDataNum= @userDataNum + @userDataHS
    @vnxType= (@nDesktops.to_i < 1501 ? "VNX5300" : "VNX5500")
    @vnxType= (@nDesktops.to_i > 3000 ? "VNX5700" : @vnxType)
    @vnxType= (@nDesktops.to_i > 4500 ? "VNX7500" : @vnxType)
    @vnxType= (@nDesktops.to_i > 7500 ? "Use Multiple VNX Arrays" : @vnxType)
    @adjvnxType= (@adjMover.to_i == 2 ? "VNX5300" : "VNX5300")
    @adjvnxType= (@adjMover.to_i > 2 ? "VNX5500" : @adjvnxType)
    @adjvnxType=(@adjMover.to_i == 4 ? "VNX5700" : @adjvnxType)
    @adjvnxType=(@adjMover.to_i > 4 ? "VNX7500" : @adjvnxType)
    @adjvnxType=(@storProto == "NFS" ? @adjvnxType : "None Needed, FC Selected")
    @moreFlash=(@nDesktops.to_i > 1000 && @vnxType == "VNX5300" ? 2 : "None")
    @baseFlashhelp=@adjNumBlk.to_i * 2
    @baseFlash=(@baseImg.to_i < 8 ? "None" : @baseFlashhelp)
    @lic=(@adjuserData.to_i > 0 ? "CIFS" : "No File")
    @lic=(@storProto == "NFS" && @adjuserData.to_i > 0 ? "NFS,CIFS" : @lic)
    erb :calc_home 
end



