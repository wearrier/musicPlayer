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
    @State var isImporting: Bool = false
    @State var selectedList: Int? = 0
    
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
                Text("Index : \(n) [\(music.fileList[n])]").tag(music.fileList[n])
                //タップするとその場所から再生
                .onTapGesture(count: 2)
                {
                    selectedList = n
                    print (music.fileList[n])
                    music.play(index: n)
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
        }
    }
        
    //配置
    var body: some View
    {
        VStack()
        {
            seekSlider()
            playTimer()
            playList()

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
                    isImporting = true
                }
            label:
                {
                    Text("プレイリストに追加")
                }
                //プレイリストを作成するためディレクトリを参照
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.folder], allowsMultipleSelection: false)
                {
                    result in
                    switch result
                    {
                    case .success(let url):
                        
                        let selected = url.filter
                        {
                            url in
                            !url.lastPathComponent.hasPrefix(".DS_Store")
                        }
                        
                        guard let selectedURL = selected.first

                        else
                        {
                            return
                        }
                        
                        self.music.url = selectedURL.path
                        
                        print(music.url)
                        
                        music.playlistAdd(contentsOf: self.music.url)
                        
                    case .failure(let error):
                        print("エラー：\(error)")
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
        }
        .padding(.all, 10)
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
