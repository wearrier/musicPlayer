//
//  Player.swift
//  musicPlayer
//
//  Created by wearrier on 2026/02/20.
//

import SwiftUI
import AVFoundation

struct Player: View
{
    @ObservedObject private var music = musicPlayer()
    @State var listingMusic = [ListMusic()]
    @State var selectedMusic: ListMusic?
    @State var selectedMusicIndex: String?
    @State var isImporting: Bool = false
    @State var selectedList: Int?
    let color1: Color = .blue
    let color2: Color = .cyan

    @ViewBuilder func seekSlider() -> some View
    {
        
        Slider(value: $music.elapsedSeconds ,in:0...music.durationTime, onEditingChanged:
                {
            EditActions in
            if EditActions == false
            {
                music.player?.currentTime = music.elapsedSeconds
            }
        })
    }
    @ViewBuilder func playTimer() -> some View
    {
        //秒数を時分に切り替える
        let formatter = DateComponentsFormatter()
        let _ = formatter.unitsStyle = .positional
        let _ = formatter.allowedUnits = [.minute, .second]
        let _ = formatter.zeroFormattingBehavior = .pad
        //再生時間と終端時間をフォーマット正しく変える
        let currentTime = formatter.string(from: music.elapsedSeconds) ?? "00:00:00"
        let duration = formatter.string(from: TimeInterval(music.player?.duration ?? 0)) ?? "00:00"
        
        //再生位置
        //再生時間 / 終端時間
        Text("\(currentTime) / \(duration)")
    }
    
    @ViewBuilder func playList() -> some View
    {
        //プレイリスト（選択可）
        List(listingMusic, id:\.id, selection: $selectedMusic)
        {
            list in
            if music.fileList.isEmpty
            {
                Text("プレイリストが空です")
            }
            
            ForEach(0..<music.fileList.count, id: \.self)
            {
                n in
                Text("Index : \(n + 1) [\(music.fileList[n])]").tag(music.fileList[n])
                //タップするとその場所から再生
                .onTapGesture(count: 2)
                {
                    selectedList = n
                    print (music.fileList[n])
                    music.play(n)
                }
                //再生曲が変わると移動する（.listRowBackgroundも同期する）
                .onChange(of: music.Index)
                {
                    if music.Index == n
                    {
                        selectedList = n
                    }
                }
                .listRowBackground(selectedList == n ? Color(.blue) : nil)
                //再生場所の下にスピーカーマークを表示
                if music.player?.isPlaying == true
                {
                    if music.Index == n
                    {
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }.listStyle(.sidebar)
    }
        
    //配置
    var body: some View
    {
        VStack(alignment: .leading)
        {
            if music.fileList.isEmpty == false
            {
                Text("Playlist Index : \(music.Index + 1) / \(music.fileList.endIndex)")
            }
        }
        VStack()
        {
            if music.player?.isPlaying == true
            {
                seekSlider()
                playTimer()
            }
            
            playList()
            
            //操作各種
            HStack()
            {
                
                Button
                {
                    music.backPlay()
                    music.stop()
                    music.play(music.Index)
                }
            label:
                {
                    Text("前の曲再生")
                }
                
                //再生ボタン
                Button
                {
                    selectedList = music.Index
                    music.play(music.Index)
                }
            label:
                {
                    Text("再生")
                }
                //停止ボタン
                Button
                {
                    music.stop()
                }
            label:
                {
                    Text("停止")
                }
                Button
                {
                    music.nextPlay()
                    music.stop()
                    music.play(music.Index)
                }
            label:
                {
                    Text("次の曲再生")
                }
               //ファイル一覧登録
                Button
                {
                    isImporting = true
                }
            label:
                {
                    Text("プレイリストに追加")
                }
                //プレイリストを作成するためディレクトリを参照
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [UTType.folder], allowsMultipleSelection: false)
                {
                    result in
                    switch result
                    {
                    case .success(let urls):
                        self.music.url = urls.first!.path
                        
                        music.playlistAdd(contentsOf: music.url)
                        
                    case .failure(let error):
                        print("エラー：\(error.localizedDescription)")
                    }
                }
                Toggle(isOn: $music.isLoop)
                {
                    Text("ループ")
                }
                Toggle(isOn: $music.isRandom)
                {
                    Text("シャッフル")
                }
            }
            VStack
            {
                HStack()
                {
                    if music.player?.isPlaying == true
                    {
                        Text("Left")
                        ZStack
                        {
                            VStack
                            {
                                VolumeBar(power: music.leftPower, normalizedPower: music.normalized(music.rightPower))
                            }
                        }
                        Text("Right")
                        ZStack
                        {
                            VStack
                            {
                                VolumeBar(power: music.rightPower, normalizedPower: music.normalized(music.rightPower))
                            }
                        }
                    }
                }
            }
        }
        .animation(.easeOut(duration: 0.05), value: music.leftPower)
    }
        
    static func terminateApp()
    {
        NSApplication.shared.terminate(self)
    }
}

extension String
{
    func StartsWith(_ prefix: String) -> Bool
    {
        return self.hasPrefix(prefix)
    }
}

#Preview
{
    Player()
}
