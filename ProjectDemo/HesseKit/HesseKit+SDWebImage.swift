//
//  HesseKit+SDWebImage.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 29/5/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

#if canImport(SDWebImage)

import SDWebImage

extension UIImageView {
    
    func setAvatar(src: URL?,
                   forFemaleUser: Bool = false,
                   placeholderImage: UIImage? = HesseKitConfig.defaultPlaceholderImage,
                   nilSrcFallbackImage: UIImage? = HesseKitConfig.defaultNilSrcFallbackImage,
                   useTransitionEffect: Bool = true,
                   completionHandler: SDExternalCompletionBlock? = nil) {
        if src == nil {
            sd_cancelCurrentImageLoad()
            sd_imageIndicator?.stopAnimatingIndicator()
            image = nilSrcFallbackImage ?? (forFemaleUser ? HesseKitConfig.defaultFemaleProfileImage : HesseKitConfig.defaultMaleProfileImage) ?? placeholderImage
        } else {
            sd_cancelCurrentImageLoad()
            setImage(src: src,
                     placeholderImage: placeholderImage,
                     nilSrcFallbackImage: nilSrcFallbackImage,
                     useTransitionEffect: useTransitionEffect,
                     completionHandler: completionHandler)
        }
    }
    
    func setImage(src url: URL?,
                  placeholderImage: UIImage? = HesseKitConfig.defaultPlaceholderImage,
                  nilSrcFallbackImage: UIImage? = HesseKitConfig.defaultNilSrcFallbackImage,
                  useTransitionEffect: Bool = true,
                  completionHandler: SDExternalCompletionBlock? = nil) {
        
        guard let URL = url else {
            sd_cancelCurrentImageLoad()
            sd_imageIndicator?.stopAnimatingIndicator()
            image = nilSrcFallbackImage ?? placeholderImage
            dprint("Error: Invalid url passed to retrieve an image: \(url?.absoluteString ?? "nil")")
            return
        }
        
        if useTransitionEffect {
            sd_imageTransition = .fade
        }
        sd_cancelCurrentImageLoad()
        sd_setImage(
            with: URL,
            placeholderImage: placeholderImage,
            progress: nil,
            completed: completionHandler)
        
    }
    
}

extension UIButton {
    
    func setAvatar(src: URL?,
                   forFemaleUser: Bool = false,
                   placeholderImage: UIImage? = HesseKitConfig.defaultPlaceholderImage,
                   nilSrcFallbackImage: UIImage? = HesseKitConfig.defaultNilSrcFallbackImage,
                   for state: UIControl.State,
                   useTransitionEffect: Bool = true,
                   completionHandler: SDExternalCompletionBlock? = nil) {
        if src == nil {
            sd_cancelCurrentImageLoad()
            sd_imageIndicator?.stopAnimatingIndicator()
            let image = nilSrcFallbackImage ?? (forFemaleUser ? HesseKitConfig.defaultFemaleProfileImage : HesseKitConfig.defaultMaleProfileImage) ?? placeholderImage
            setBackgroundImage(image, for: state)
        } else {
            sd_cancelCurrentImageLoad()
            setBackgroundImage(src: src,
                               placeholderImage: placeholderImage,
                               nilSrcFallbackImage: nilSrcFallbackImage,
                               for: state,
                               useTransitionEffect: useTransitionEffect,
                               completionHandler: completionHandler)
        }
    }
    
    func setImage(src url: URL?,
                  placeholderImage: UIImage? = HesseKitConfig.defaultPlaceholderImage,
                  nilSrcFallbackImage: UIImage? = HesseKitConfig.defaultNilSrcFallbackImage,
                  for state: UIControl.State,
                  useTransitionEffect: Bool = true,
                  completionHandler: SDExternalCompletionBlock? = nil) {
        
        guard let URL = url else {
            sd_cancelCurrentImageLoad()
            sd_imageIndicator?.stopAnimatingIndicator()
            setImage(nilSrcFallbackImage ?? placeholderImage, for: state)
            dprint("Error: Invalid url passed to retrieve an image: \(url?.absoluteString ?? "nil")")
            return
        }
        if useTransitionEffect {
            sd_imageTransition = .fade
        }
        sd_cancelCurrentImageLoad()
        sd_setImage(
            with: URL,
            for: state,
            placeholderImage: placeholderImage,
            completed: completionHandler)
    }
    
    func setBackgroundImage(src url: URL?,
                            placeholderImage: UIImage? = HesseKitConfig.defaultPlaceholderImage,
                            nilSrcFallbackImage: UIImage? = HesseKitConfig.defaultNilSrcFallbackImage,
                            for state: UIControl.State,
                            useTransitionEffect: Bool = true,
                            completionHandler: SDExternalCompletionBlock? = nil) {
        
        guard let URL = url else {
            sd_cancelCurrentImageLoad()
            sd_imageIndicator?.stopAnimatingIndicator()
            setBackgroundImage(nilSrcFallbackImage ?? placeholderImage, for: state)
            dprint("Error: Invalid url passed to retrieve an image: \(url?.absoluteString ?? "nil")")
            return
        }
        
        if useTransitionEffect {
            sd_imageTransition = .fade
        }
        sd_cancelCurrentImageLoad()
        sd_setBackgroundImage(
            with: URL,
            for: state,
            placeholderImage: placeholderImage,
            completed: completionHandler)
    }
}

#endif
