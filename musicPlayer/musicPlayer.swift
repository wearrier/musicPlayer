//
//  musicPlayer.swift
//  musicPlayer
//
//  Created by wearrier on 2026/02/24.
//

import SwiftUI
import Foundation
import AVFoundation
internal import Combine

struct ListMusic : Identifiable, Hashable
{
    var id: [String] = []
}

internal final class musicPlayer: NSObject, ObservableObject
{
    //プレイヤー
    @Published var player: AVAudioPlayer? = nil
    //ファイルパス
    @Published var url: String = ""
    @Published var listOfName: String = ""
    //タイマー
    @Published var timer: Timer? = nil
    @Published var elapsedSeconds: Double = 0.0
    @Published var durationTime: Double = 0.0
    //ファイルのリスト
    @Published var fileList: [String] = []
    @Published var Index: Int = 0
    
    //ランダム要素オン／オフ
    @Published var isRandom: Bool = false
    
    //ループ設定
    @Published var isLoop: Bool = false
        
    override init ()
    {
        let player = AVAudioPlayer()
        self.player = player
        
        let timer = Timer()
        self.timer = timer
        
        super.init()
    }

    //再生処理
    func play(index: Int)
    {
        //プレイリストが存在しない場合はエラー
        if fileList.isEmpty == true
        {
            print ("ファイルがありません。")
            return
        }
        
        //プレイリストが存在していれば再生
        else if fileList.isEmpty == false
        {
            if(isRandom == true)
            {
                self.Index = Int.random(in: 0..<Index)
            }
            
            // Indexが -1 以下になっていた場合 0 に戻す
            if Index <= -1
            {
                Index = 0
                return
            }
            Index = Int(index)
            
            listOfName = url + "/" + fileList[Index]
            
            //再生処理
            let playerURL = URL(fileURLWithPath: listOfName)
            do
            {
                print(listOfName)
                player = try AVAudioPlayer(contentsOf: playerURL)
                Loop()
                if(player?.isPlaying == false)
                {
                    player?.delegate = self
                    player?.play()
                    //ファイルの最終端を取得
                    durationTime = player!.duration
                    
                }
            }
            catch
            {
                print ("Error loading audio file[Error: \(error)]")
            }
        }
        //再生時間取得
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true)
        {
            _ in
            self.elapsedSeconds = self.player!.currentTime
        }
    }
    
    //停止処理
    func stop()
    {
        player?.stop()
        player?.currentTime = 0.0
    }
    
    //プレイリスト生成
    func playlistAdd(contentsOf: String)
    {
        let fileManager = FileManager.default
        
        do
        {
            self.fileList = try fileManager.contentsOfDirectory(atPath: contentsOf)
            print("\(self.fileList)")
        }
        catch
        {
            print("Error retrieving files from directory.")
            return
        }
    }
    
    //ループ
    func Loop()
    {
        player?.numberOfLoops = isLoop ? -1 : 0
    }
    //次
    func nextPlay()
    {
        if(Index == fileList.endIndex - 1)
        {
            Index = fileList.startIndex - 1
        }
        
        if(Index >= fileList.startIndex - 1)
        {
            Index += 1
        }
    }
    //戻る
    func backPlay()
    {
        if(Index == fileList.startIndex)
        {
            Index = fileList.endIndex
        }
        
        if(Index <= fileList.endIndex)
        {
            Index -= 1
        }
    }
}

extension musicPlayer: AVAudioPlayerDelegate
{
    //終端まで来たら次の曲再生
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        nextPlay()
        play(index: Index)
    }
}
