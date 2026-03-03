//
//  Player.swift
//  musicPlayer
//
//  Created by wearrier on 2026/02/20.
//

import SwiftUI
import AVFoundation

struct listMusic : Identifiable
{
    let name: String
    let id: UUID = UUID()
}
struct Player: View
{
    @Environment(\.dismiss) var dismiss
    @ObservedObject var music = musicPlayer()
    @State var listMucsic = Set<UUID>()
    
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
        //プレイリスト
        NavigationStack
        {
            List(selection: $listMucsic)
            {
                if(music.fileList.count == 0)
                {
                    Text("リストが空です")
                }
                
                ForEach(music.fileList, id: \.self)
                {
                    list in
                    let n = music.fileList.firstIndex(of: list)!
                    Text("Index : \(n) [\(music.fileList[n])]")
                }
            }
        }.navigationTitle("オーディオプレイヤー")
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
                    music.play()
                }
            label:
                {
                    Text("前の曲再生")
                }
                
                //再生ボタン
                Button
                {
                    music.play()
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
                    music.play()
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
