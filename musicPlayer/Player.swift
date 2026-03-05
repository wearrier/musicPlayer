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
    @ObservedObject var music: musicPlayer = musicPlayer()
    @State var listingMusic = [ListMusic()]
    @State var selectedMusic: ListMusic?
    @State var selectedMusicIndex: String?
   
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
        
        Text("再生場所 : \(music.listOfName)")
        
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
                Text("Index : \(n) [\(music.fileList[n])]")
                    .listRowBackground(selectedMusic == list ? Color.blue : Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2)
                {
                    print (music.fileList[n])
                    if(music.isRandom == true)
                    {
                        music.fileList.shuffle()
                        music.isRandom = false
                    }
                    music.play(index: n)
                 }
            }
        }.listStyle(SidebarListStyle())
    }
    
    @ViewBuilder func folderSelector() -> some View
    {
        //フォルダ選択
        TextField("曲の場所を指定", text: $music.url)
        Text("\(music.url)")
    }
    
    //配置
    var body: some View
    {
        VStack()
        {
            seekSlider()
            playTimer()
            playList()
            folderSelector()
            
            //操作各種
            HStack()
            {
                Button
                {
                    music.backPlay()
                    music.stop()
                    music.play(index: music.Index)
                }
            label:
                {
                    Text("前の曲再生")
                }
                
                //再生ボタン
                Button
                {
                    music.play(index: music.Index)
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
                    music.play(index: music.Index)
                }
            label:
                {
                    Text("次の曲再生")
                }
                //ファイル一覧登録
                Button
                {
                    music.playlistAdd()
                }
            label:
                {
                    Text("プレイリストに追加")
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
        }
        .padding(.all, 10)
    }
    
    static func terminateApp()
    {
        NSApplication.shared.terminate(self)
    }
}

#Preview
{
    Player()
}
