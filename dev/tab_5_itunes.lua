PANEL = {}
PANEL.Name = "iTunes"
PANEL.Desc = "Control iTunes from GMod"
PANEL.TabIcon = "gui/silkicons/music"
PANEL.iTunes = itunes.CreateInterface()
PANEL.Skin = "" -- _blue

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	
	self.ControlPanel = vgui.Create("DPanel",self)
	--self.SongList = vgui.Create("DPanel",self)
	--self.PlayList = vgui.Create("DPanel",self)
	
	self.PlayState = tobool(self.iTunes:GetPlayerState())
		
	self.Button_PlayStop = vgui.Create("DImageButton",self.ControlPanel)
	self.Button_PlayStop:SetPos(40,20)
	self.Button_PlayStop:SetSize(16,16)
	self.Button_PlayStop:SetImage((tobool(self.iTunes:GetPlayerState()) == true and "gui/silkicons/control_stop" or "gui/silkicons/control_play")..self.Skin)
	self.Button_PlayStop.DoClick = function(btn)
		if tobool(self.iTunes:GetPlayerState()) == true then
			btn:SetImage("gui/silkicons/control_play"..self.Skin)
			self.iTunes:Stop()
		else
			btn:SetImage("gui/silkicons/control_stop"..self.Skin)
			self.iTunes:Play()
		end
	end
	
	self.Button_Next = vgui.Create("DImageButton",self.ControlPanel)
	self.Button_Next:SetPos(60,20)
	self.Button_Next:SetSize(16,16)
	self.Button_Next:SetImage("gui/silkicons/control_fastforward"..self.Skin)
	self.Button_Next.DoClick = function(btn)
		self.iTunes:NextTrack()
	end
	
	self.Button_Back = vgui.Create("DImageButton",self.ControlPanel)
	self.Button_Back:SetPos(20,20)
	self.Button_Back:SetSize(16,16)
	self.Button_Back:SetImage("gui/silkicons/control_rewind"..self.Skin)
	self.Button_Back.DoClick = function(btn)
		self.iTunes:BackTrack()
	end
	
	self.Slider_Volume = vgui.Create("DSlider",self.ControlPanel)
	self.Slider_Volume:SetPos(100,21)
	self.Slider_Volume:SetSize(150,13)
	self.Slider_Volume:SetLockY(0.5)
	self.Slider_Volume:SetTrapInside(true)
	self.Slider_Volume:SetImage("vgui/slider")
	self.Slider_Volume:SetSlideX(self.iTunes:GetSoundVolume()/100)
	self.Slider_Volume.TranslateValues = function(slider,x,y)
		x = math.floor(x*100)/100
		self.iTunes:SetSoundVolume(x*100)
		return x,y
	end
	Derma_Hook(self.Slider_Volume,"Paint","Paint","NumSlider")	
	
	self.CurrentTrack = self.iTunes:GetCurrentTrack()
	self.CurrentTitle = self.CurrentTrack:GetName()
	self.CurrentArtist = self.CurrentTrack:GetArtist()
	
	self.PlayerPosition = math.floor(self.iTunes:GetPlayerPosition() / self.CurrentTrack:GetDuration() * 100)
	
	self.Info_CurrentTrack = vgui.Create("DPanel",self.ControlPanel)
	self.Info_CurrentTrack:SetSize(500,55)
	self.Info_CurrentTrack.OldPaint = self.Info_CurrentTrack.Paint
	self.Info_CurrentTrack.Paint = function(pnl)
		self.Info_CurrentTrack.OldPaint(pnl)
		draw.DrawText(self.CurrentArtist.." - "..self.CurrentTitle,"Default",100,10,Color(255,255,255,255),ALIGN_LEFT)
	end
	
	self.Slider_Track = vgui.Create("DSlider",self.Info_CurrentTrack)
	self.Slider_Track:SetPos(100,31)
	self.Slider_Track:SetSize(300,13)
	self.Slider_Track:SetLockY(0.5)
	self.Slider_Track:SetTrapInside(true)
	self.Slider_Track:SetImage("vgui/slider")
	self.Slider_Track:SetSlideX(self.PlayerPosition/100)
	self.Slider_Track.TranslateValues = function(slider,x,y)
		x = math.floor(x*100)/100
		self.iTunes:SetPlayerPosition(x*100)
		return x,y
	end
	Derma_Hook(self.Slider_Track,"Paint","Paint","NumSlider")
	
	self.TrackList = vgui.Create("DListView",self)
	self.TrackList:AddColumn("Title"):SetFixedWidth(400)
	self.TrackList:AddColumn("Artist"):SetFixedWidth(200)
	self.TrackList:AddColumn("Album"):SetFixedWidth(200)
	self.TrackList:AddColumn("Last Played")
	self.TrackList:SetDataHeight(16)
	
	self.CurrentPlayList = self.iTunes:GetCurrentPlaylist()
	
	function LoadPlayList(lib)
		self.TrackList:Clear()
		local tracklist = lib:GetTracks()
		for i=1,tracklist:GetCount() do
			local track = tracklist:GetItem(i)
			local name = track:GetName()
			local artist = track:GetArtist()
			local album = track:GetAlbum()
			local last = track:GetPlayedDate()
			
			self.TrackList:AddLine(name,artist,album,last)
		end
	end
	LoadPlayList(self.CurrentPlayList)
	
	self.PlayList = vgui.Create("DListView",self)
	self.PlayList:AddColumn("PlayLists")
	self.PlayList:SetDataHeight(16)
	self.PlayList:SetMultiSelect(false)
	self.PlayList.OnClickLine = function(parent,line,selected)
		line:SetSelected(true)
		local lib = self.PlayListLib:GetItemByName(line:GetValue(1))
		if lib then LoadPlayList(lib) end
	end
	
	self.Source = self.iTunes:GetLibrarySource()
	self.PlayListLib = self.Source:GetPlaylists()
	for i=1,self.PlayListLib:GetCount() do
		local playlist = self.PlayListLib:GetItem(i)
		local name = playlist:GetName()
		if !table.HasValue({"Mediathek","Filme","Fernsehsendungen","Podcasts","Einkäufe","Genius","iTunes DJ","Klassische Musik","Zuletzt Hinzugefügt"},name) then
			self.PlayList:AddLine(name)
		end
	end
	
	
	/*
	itunes.CreateInterface()

	IiTunes:Release()
	IiTunes:BackTrack()
	IiTunes:FastForward()
	IiTunes:GetCurrentStreamTitle()
	IiTunes:GetCurrentStreamURL()
	IiTunes:GetCurrentPlaylist()
	IiTunes:GetCurrentTrack()
	IiTunes:GetLibraryPlaylist()
	IiTunes:GetLibrarySource()
	IiTunes:GetMute()
	IiTunes:GetPlayerPosition()
	IiTunes:GetPlayerState()
	IiTunes:GetSoundVolume()
	IiTunes:GetSources()
	IiTunes:GetVersion()
	IiTunes:NextTrack()
	IiTunes:Pause()
	IiTunes:Play()
	IiTunes:PlayFile(filePath)
	IiTunes:PlayPause()
	IiTunes:PreviousTrack()
	IiTunes:Quit()
	IiTunes:Resume()
	IiTunes:Rewind()
	IiTunes:SetMute(mute)
	IiTunes:SetPlayerPosition(position)
	IiTunes:SetSoundVolume(volume)
	IiTunes:Stop()
	IiTunes:SubscribeToPodcast(url)
	IiTunes:UpdateIPod()
	IiTunes:UpdatePodcastFeeds()

	IITTrack:Release()
	IITTrack:GetIndex()
	IITTrack:GetName()
	IITTrack:GetPlaylistID()
	IITTrack:GetSourceID()
	IITTrack:GetTrackDatabaseID()
	IITTrack:GetTrackID()
	IITTrack:SetName()
	IITTrack:Delete()
	IITTrack:GetAlbum()
	IITTrack:GetArtist()
	IITTrack:GetBitRate()
	IITTrack:GetBPM()
	IITTrack:GetComment()
	IITTrack:GetCompilation()
	IITTrack:GetComposer()
	IITTrack:GetDateAdded()
	IITTrack:GetDiscCount()
	IITTrack:GetDiscNumber()
	IITTrack:GetDuration()
	IITTrack:GetEnabled()
	IITTrack:GetEQ()
	IITTrack:GetFinish()
	IITTrack:GetGenre()
	IITTrack:GetGrouping()
	IITTrack:GetKind()
	IITTrack:GetModificationDate()
	IITTrack:GetPlayedCount()
	IITTrack:GetPlayedDate()
	IITTrack:GetPlaylist()
	IITTrack:GetPlayOrderIndex()
	IITTrack:GetRating()
	IITTrack:GetSampleRate()
	IITTrack:GetSize()
	IITTrack:GetStart()
	IITTrack:GetTime()
	IITTrack:GetTrackCount()
	IITTrack:GetTrackNumber()
	IITTrack:GetVolumeAdjustment()
	IITTrack:GetYear()
	IITTrack:Play()
	IITTrack:SetAlbum(album)
	IITTrack:SetArtist(artist)
	IITTrack:SetBPM(bpm)
	IITTrack:SetComment(comment)
	IITTrack:SetCompilation(compilation)
	IITTrack:SetComposer(composer)
	IITTrack:SetDiscCount(discCount)
	IITTrack:SetDiscNumber(discNumber)
	IITTrack:SetEnabled(enabled)
	IITTrack:SetEQ(eq)
	IITTrack:SetFinish(finish)
	IITTrack:SetGenre(genre)
	IITTrack:SetGrouping(grouping)
	IITTrack:SetPlayedCount(count)
	IITTrack:SetPlayedDate(playedDate)
	IITTrack:SetRating(rating)
	IITTrack:SetStart(start)
	IITTrack:SetTrackCount(trackCount)
	IITTrack:SetTrackNumber(trackNumber)
	IITTrack:SetVolumeAdjustment(adjustment)
	IITTrack:SetYear(year)

	IITTrackCollection:Release()
	IITTrackCollection:GetCount()
	IITTrackCollection:GetItem(index)
	IITTrackCollection:GetItemByName(name)

	IITPlaylist:Release()
	IITPlaylist:GetIndex()
	IITPlaylist:GetName()
	IITPlaylist:GetPlaylistID()
	IITPlaylist:GetSourceID()
	IITPlaylist:SetName(name)
	IITPlaylist:Delete()
	IITPlaylist:GetDuration()
	IITPlaylist:GetKind()
	IITPlaylist:GetShuffle()
	IITPlaylist:GetSize()
	IITPlaylist:GetSongRepeat()
	IITPlaylist:GetSource()
	IITPlaylist:GetTime()
	IITPlaylist:GetTracks()
	IITPlaylist:GetVisible()
	IITPlaylist:PlayFirstTrack()
	IITPlaylist:Search(search, field)
	IITPlaylist:SetShuffle(shuffle)
	IITPlaylist:SetSongRepeat(mode)

	IITPlaylistCollection:Release()
	IITPlaylistCollection:GetCount()
	IITPlaylistCollection:GetItem(index)
	IITPlaylistCollection:GetItemByName(name)

	IITSource:Release()
	IITSource:GetIndex()
	IITSource:GetName()
	IITSource:GetSourceID()
	IITSource:SetName(name)
	IITSource:GetCapacity()
	IITSource:GetFreeSpace()
	IITSource:GetKind()
	IITSource:GetPlaylists()

	IITSourceCollection:Release()
	IITSourceCollection:GetCount()
	IITSourceCollection:GetItem(index)
	IITSourceCollection:GetItemByName(name)
	*/

	
	function GetiTunes()
		return self
	end
end

function PANEL:PerformLayout()
	self:StretchToParent(4,27,4,4)
	self.ControlPanel:StretchToParent(0,0,0,self:GetTall() - 55)
	self.TrackList:StretchToParent(200,60,0,0)	
	self.PlayList:StretchToParent(0,60,self:GetWide() - 195,0)
	self.Info_CurrentTrack:SetPos(math.max(270,self:GetWide()/2 - 250),0)
end

function PANEL:Paint()
end

