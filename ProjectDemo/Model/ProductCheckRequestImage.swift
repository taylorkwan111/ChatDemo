import SwiftyJSON

struct ProductCheckRequestImage: JSONWrapperModel {

	let json: JSON

	init(json: JSON) {
		self.json = json
	}
    
    
    var imageUrl: URL? {
        return json["image_url"].url
    }

    // This string value is a stringified JSON object, e.g. {"index":0}
    var userComment: String? {
        return json["user_comment"].string
    }

    var createdAt: String? {
        return json["created_at"].string
    }

    var format: String? {
        return json["format"].string
    }

    var id: Int? {
        return json["id"].int
    }

    var width: Int? {
        return json["width"].int
    }

    var checkerComment: String? {
        return json["checker_comment"].string
    }

    var requestId: Int? {
        return json["request_id"].int
    }

    var height: Int? {
        return json["height"].int
    }

    var userId: Int? {
        return json["user_id"].int
    }

    var updatedAt: String? {
        return json["updated_at"].string
    }

}


extension ProductCheckRequestImage {
//
//    var resizedImageUrl_short300: URL? {
//        imageUrl?.applyingAlicloudImageResizing(shortEdge: 300)
//    }
//
//    var resizedImageUrl_short2000: URL? {
//        imageUrl?.applyingAlicloudImageResizing(shortEdge: 2000)
//    }
    
    // Starting from 0.
    var indexEmbeddedInUserComment: Int? {
        if let userComment = userComment, let index = JSON(parseJSON: userComment)["index"].int {
            return index
        }
        return nil
    }
    
}
